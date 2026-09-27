#!/usr/bin/env bash

# Shared helpers for the caching and reporting jobs.
# Requires AXOLOTL_REPO (and DEFAULT_REFS for collect_refs) in the environment.

# Resolve a branch, tag, or commit to a commit hash.
sha_of() {
  local ref="$1" raw peeled branch tag
  if [[ "$ref" =~ ^[0-9a-f]{40}$ ]]; then
    printf '%s' "$ref"
    return
  fi
  raw="$(git ls-remote "${AXOLOTL_REPO}" \
    "refs/tags/${ref}^{}" "refs/heads/${ref}" "refs/tags/${ref}" 2>/dev/null || true)"
  peeled="$(awk -v r="refs/tags/${ref}^{}" '$2==r { print $1; exit }' <<< "$raw")"
  branch="$(awk -v r="refs/heads/${ref}" '$2==r { print $1; exit }' <<< "$raw")"
  tag="$(awk -v r="refs/tags/${ref}" '$2==r { print $1; exit }' <<< "$raw")"
  printf '%s' "${peeled:-${branch:-$tag}}"
}

# Flake reference for one commit ($1). shallow=1 asks for just that commit's
# tree; without it, every rev costs a full clone of the repository's history.
flake_ref() {
  printf '%s?shallow=1&rev=%s' "$AXOLOTL_FLAKE" "$1"
}

# Store path of the wrapper derivation (default == axolotl-launcher ==
# symlinkJoin { enwrap desktop }) for one system and commit.
# Requires AXOLOTL_FLAKE and BUILD_ATTR.
wrapper_drv_of() {
  nix eval --raw --accept-flake-config \
    "$(flake_ref "$2")#packages.$1.${BUILD_ATTR}.drvPath" 2>/dev/null
}

# The axolotl-<version> derivation inside a wrapper closure. Takes the wrapper's
# store path; requires CACHIX_PUSH_PATTERN.
axolotl_drv_in() {
  nix-store -qR "$1" 2>/dev/null | grep -E -e "${CACHIX_PUSH_PATTERN}" | grep -E '\.drv$' | head -1
}

# Resolve a commit straight to that derivation's store path.
rust_drv_of() {
  local drv
  drv="$(wrapper_drv_of "$1" "$2")" || return 1
  [ -z "$drv" ] && return 1
  axolotl_drv_in "$drv"
}

# Populate the global REFS array:
#   - manual run: the space-separated INPUT_REF
#   - scheduled run: latest stable + preview releases, then DEFAULT_REFS
collect_refs() {
  REFS=()
  if [ -n "${INPUT_REF:-}" ]; then
    read -ra REFS <<< "$INPUT_REF"
    return
  fi

  local api releases stable preview defaults
  api="${AXOLOTL_REPO/github.com/api.github.com/repos}"
  releases="$(curl -fsSL "${api}/releases?per_page=20" || true)"
  releases="${releases:-[]}"
  stable="$(jq -r '[.[] | select((.draft | not) and (.prerelease | not))][0].tag_name // empty' <<< "$releases")"
  preview="$(jq -r '[.[] | select((.draft | not) and .prerelease)][0].tag_name // empty' <<< "$releases")"

  [ -n "$stable" ] && REFS+=("$stable")
  [ -n "$preview" ] && REFS+=("$preview")
  read -ra defaults <<< "$DEFAULT_REFS"
  REFS+=("${defaults[@]}")
}
