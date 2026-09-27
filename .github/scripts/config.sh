#!/usr/bin/env bash

# config.json, read once. Sourced, it puts the values in the caller's
# environment; run directly — the workflow's "Load config" step — it also
# publishes them as step outputs for the expressions that need one.
#
# Set CONFIG_FILE to read a different file.

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -euo pipefail
fi

CONFIG_FILE="${CONFIG_FILE:-config.json}"

config_load() {
  local -a v=()

  mapfile -t v < <(jq -r '.axolotl_repo, .cache_store, .cachix_name, .version_fmt, (.default_refs | join(" "))' "$CONFIG_FILE")

  AXOLOTL_REPO="${v[0]}"
  CACHE_STORE="${v[1]}"
  CACHIX_NAME="${v[2]}"
  VERSION_FMT="${v[3]}"
  DEFAULT_REFS="${v[4]}"

  # Derived here rather than in the workflow, so no caller has to remember the
  # `git+` prefix or the leading dash of the store-name pattern.
  AXOLOTL_FLAKE="git+${AXOLOTL_REPO}"
  CACHIX_PUSH_PATTERN="-axolotl-${VERSION_FMT}"

  export AXOLOTL_REPO AXOLOTL_FLAKE CACHE_STORE CACHIX_NAME VERSION_FMT \
    DEFAULT_REFS CACHIX_PUSH_PATTERN
}

config_load

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  {
    printf 'axolotl_repo=%s\n' "$AXOLOTL_REPO"
    printf 'cache_store=%s\n' "$CACHE_STORE"
    printf 'cachix_name=%s\n' "$CACHIX_NAME"
    printf 'version_fmt=%s\n' "$VERSION_FMT"
    printf 'default_refs=%s\n' "$DEFAULT_REFS"
  } >> "${GITHUB_OUTPUT:?GITHUB_OUTPUT is not set}"
fi
