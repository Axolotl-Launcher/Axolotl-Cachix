#!/usr/bin/env bash
#
# Build and push every commit in $RUNNER_TEMP/todo for one system, recording a
# failure count for each commit that cannot be built.
#
# Requires SYSTEM, RUNNER_TEMP and BUILD_TIMEOUT; reads config.json for the
# cache name. Exits non-zero when not a single ref could be cached.
set -euo pipefail

source "$(dirname "$0")/fail-counts.sh"
source "$(dirname "$0")/config.sh"

fail_counts_load

# Each ref is built independently: a failure is recorded and the loop moves on
# to the next ref, so a broken release cannot block the refs queued behind it. A
# partially broken ref set is reported as a warning but keeps the run green;
# only an all-failure set turns the job red.
failed=()
attempted=0
cached=0
while read -r sha drv; do
  [ -z "$drv" ] && continue
  attempted=$((attempted + 1))
  echo "::group::Caching ${sha} (${SYSTEM})"

  # timeout(1) exits 124 on timeout; --kill-after covers a nix build that
  # ignores SIGTERM. A timed-out ref is recorded like a failed one.
  rc=0
  outs="$(timeout --kill-after=60s "${BUILD_TIMEOUT:-60m}" \
    nix build --no-link --print-out-paths "${drv}^*")" || rc=$?
  if [ "$rc" -ne 0 ]; then
    if [ "$rc" -eq 124 ]; then
      echo "Build timed out for ${sha} (${SYSTEM}) after ${BUILD_TIMEOUT:-60m}"
    else
      echo "Build failed for ${sha} (${SYSTEM}) with exit ${rc}"
    fi
    # Only a failed `nix build` counts towards the limit. A failed push does
    # not: the commit itself builds, and counting it would blacklist a ref whose
    # output never reached the cache.
    fail_counts_bump "$sha"
    failed+=("${sha}")
    echo "::endgroup::"
    continue
  fi

  mapfile -t paths < <(printf '%s\n' "$outs" | grep -v '^$')
  if [ ${#paths[@]} -eq 0 ]; then
    echo "Build for ${sha} (${SYSTEM}) produced no outputs"
    failed+=("${sha}")
    echo "::endgroup::"
    continue
  fi

  if ! cachix push "${CACHIX_NAME}" "${paths[@]}"; then
    echo "Push failed for ${sha} (${SYSTEM})"
    failed+=("${sha}")
    echo "::endgroup::"
    continue
  fi

  printf 'Pushed %s\n' "${paths[@]}"
  cached=$((cached + 1))
  echo "::endgroup::"
done < "$RUNNER_TEMP/todo"

# Written even when nothing failed, so the file always holds the state the save
# step stores at the end of the job.
fail_counts_save "$RUNNER_TEMP/seen-sha"

# One cached ref is enough to keep the run green: a single broken commit (e.g. a
# release tag that does not build) must not fail the schedule forever. Fail only
# when nothing at all could be cached.
if [ ${#failed[@]} -gt 0 ]; then
  echo "::warning::Failed refs on ${SYSTEM}: ${failed[*]}"
fi
if [ $attempted -gt 0 ] && [ $cached -eq 0 ]; then
  echo "::error::No ref could be cached on ${SYSTEM}: ${failed[*]}"
  exit 1
fi
