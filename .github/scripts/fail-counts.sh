#!/usr/bin/env bash

# Per-system failure counts for commit-pinned refs, kept in a file that
# actions/cache saves at the end of the job.
#
# A ref that cannot be built fails the same way on every run: its commit is
# pinned, so a failing `nix build` is reproducible. Counting those failures lets
# later runs skip the ref instead of spending the job budget on it again.
#
# FAIL_THRESHOLD defaults to 3. The counts file defaults to
# $RUNNER_TEMP/fail-counts-$SYSTEM.txt and can be overridden with
# FAIL_COUNTS_FILE; the path is resolved when it is used, not when this file is
# sourced, so callers without SYSTEM set can still use fail_counts_load_file.

FAIL_THRESHOLD="${FAIL_THRESHOLD:-3}"

declare -A FAIL_COUNT=()

# Path of the counts file this shell reads and writes.
fail_counts_file() {
  printf '%s' "${FAIL_COUNTS_FILE:-${RUNNER_TEMP}/fail-counts-${SYSTEM}.txt}"
}

# Read one counts file into FAIL_COUNT, ignoring malformed lines. Each line is
# `_<sha>=<count>`: the leading underscore exists only so the key would also be
# usable as a shell variable name, since a commit hash may start with a digit.
fail_counts_load_file() {
  FAIL_COUNT=()
  local file="$1" k v
  [ -f "$file" ] || return 0
  while IFS='=' read -r k v; do
    k="${k#_}"
    case "$k" in ''|'#'*) continue ;; esac
    case "$v" in ''|*[!0-9]*) continue ;; esac
    FAIL_COUNT["$k"]="$v"
  done < "$file"
}

fail_counts_load() {
  fail_counts_load_file "$(fail_counts_file)"
}

fail_count_of() {
  printf '%s' "${FAIL_COUNT["$1"]:-0}"
}

fail_counts_blacklisted() {
  [ "$(fail_count_of "$1")" -ge "$FAIL_THRESHOLD" ]
}

fail_counts_bump() {
  FAIL_COUNT["$1"]=$(( $(fail_count_of "$1") + 1 ))
}

# Rewrite the counts file: keep every entry below the threshold, plus the
# entries whose commit is still one of the refs this run resolved to ($1 = file
# holding one sha per line). An entry at or above the threshold that no ref
# points at anymore is dropped, so the file only keeps what is still reachable.
fail_counts_save() {
  local seen="${1:-}" k v
  local file
  file="$(fail_counts_file)"
  : > "$file"
  for k in "${!FAIL_COUNT[@]}"; do
    v="${FAIL_COUNT[$k]}"
    if [ "$v" -lt "$FAIL_THRESHOLD" ]; then
      printf '_%s=%s\n' "$k" "$v"
    elif [ -n "$seen" ] && grep -qxF "$k" "$seen"; then
      printf '_%s=%s\n' "$k" "$v"
    fi
  done | sort >> "$file"
}
