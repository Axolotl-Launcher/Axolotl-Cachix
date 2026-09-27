#!/usr/bin/env bash
#
# Build the todo list of one system: every commit whose output is missing from
# the cache, in the order it should be built, plus the pnpm-deps paths and cache
# key that go with it.
#
# Requires INPUT_REF, PNPM_DEPS_PATTERN, SYSTEM, RUNNER_TEMP and GITHUB_OUTPUT;
# reads config.json for the repository, cache and refs.
# Writes $RUNNER_TEMP/{seen-sha,todo,pnpm-deps.txt}.
set -euo pipefail

source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/fail-counts.sh"
source "$(dirname "$0")/config.sh"

fail_counts_load

# The commits this run's refs resolve to. A failure count is only dropped once
# no ref points at its commit anymore.
seen="$RUNNER_TEMP/seen-sha"
: > "$seen"

# rust_drv_of() comes from common.sh, so the report job resolves the same
# derivation with the same rule.
#
# The pnpm-deps fixed-output derivation: its store path is independent of the
# architecture, so x86_64 and aarch64 share the same path.
pnpm_drv_of() {
  local drv
  drv="$(wrapper_drv_of "$SYSTEM" "$1")" || return 1
  [ -z "$drv" ] && return 1
  nix-store -qR "$drv" 2>/dev/null | grep -E -e "${PNPM_DEPS_PATTERN}" | head -1
}

todo=()
enqueue() {
  local sha="$1" drv out
  [ -z "$sha" ] && return

  for e in "${todo[@]}"; do [ "$e" = "$sha" ] && return; done

  # Checked before resolving the derivation: a ref that is known to be broken
  # should not even pay for the `nix eval` that resolves it.
  if fail_counts_blacklisted "$sha"; then
    echo "Skipping ${sha}: failed $(fail_count_of "$sha") times on ${SYSTEM}"
    return
  fi

  if ! drv="$(rust_drv_of "$SYSTEM" "$sha")" || [ -z "$drv" ]; then
    echo "Skipping ${sha}: no ${SYSTEM} output matching '${CACHIX_PUSH_PATTERN}'"
    return
  fi

  out="$(nix-store -q --outputs "$drv")"
  if nix path-info --store "${CACHE_STORE}" "$out" >/dev/null 2>&1; then
    echo "Already cached: ${sha} (${SYSTEM}) ${out}"
    return
  fi

  echo "Needs caching: ${sha} (${SYSTEM}) ${drv}"
  todo+=("$sha")
}

collect_refs
[ ${#REFS[@]} -gt 0 ] && echo "Candidates: ${REFS[*]}"
for ref in "${REFS[@]}"; do
  sha="$(sha_of "$ref")"
  [ -n "$sha" ] && printf '%s\n' "$sha" >> "$seen"
  enqueue "$sha"
done

# <sha> <rust-drv> for each queued commit, in order.
: > "$RUNNER_TEMP/todo"
for sha in "${todo[@]}"; do
  [ -z "$sha" ] && continue
  drv="$(rust_drv_of "$SYSTEM" "$sha")" || continue
  [ -n "$drv" ] && printf '%s %s\n' "$sha" "$drv" >> "$RUNNER_TEMP/todo"
done
echo "Todo (${SYSTEM}):"
cat "$RUNNER_TEMP/todo"

# pnpm-deps store paths needed for this todo (same on every architecture).
for sha in "${todo[@]}"; do
  [ -z "$sha" ] && continue
  drv="$(pnpm_drv_of "$sha")" || continue
  [ -n "$drv" ] && nix-store -q --outputs "$drv"
done | sort -u > "$RUNNER_TEMP/pnpm-deps.txt"
echo "pnpm-deps paths:"
cat "$RUNNER_TEMP/pnpm-deps.txt"
echo "pnpm_cache_key=pnpm-deps-$(sha256sum "$RUNNER_TEMP/pnpm-deps.txt" | cut -c1-16)" >> "$GITHUB_OUTPUT"
