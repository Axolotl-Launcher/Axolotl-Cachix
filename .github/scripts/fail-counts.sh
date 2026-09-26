#!/usr/bin/env bash

# Per-system failure counts for commit-pinned refs, kept in a file that
# actions/cache saves at the end of the job.
#
# A ref that cannot be built fails the same way on every run: its commit is
# pinned, so a failing `nix build` is reproducible. Counting those failures lets
# later runs skip the ref instead of spending the job budget on it again.
#
# Requires SYSTEM and RUNNER_TEMP (FAIL_THRESHOLD defaults to 3).

FAIL_THRESHOLD="${FAIL_THRESHOLD:-3}"
FAIL_COUNTS_FILE="${FAIL_COUNTS_FILE:-${RUNNER_TEMP}/fail-counts-${SYSTEM}.txt}"

declare -A FAIL_COUNT=()

# Read the counts file, ignoring malformed lines. Each line is `_<sha>=<count>`:
# the leading underscore exists only so the key would also be usable as a shell
# variable name, since a commit hash may start with a digit.
fail_counts_load() {
  FAIL_COUNT=()
  [ -f "$FAIL_COUNTS_FILE" ] || return 0
  local k v
  while IFS='=' read -r k v; do
    k="${k#_}"
    case "$k" in ''|'#'*) continue ;; esac
    case "$v" in ''|*[!0-9]*) continue ;; esac
    FAIL_COUNT["$k"]="$v"
  done < "$FAIL_COUNTS_FILE"
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
  : > "$FAIL_COUNTS_FILE"
  for k in "${!FAIL_COUNT[@]}"; do
    v="${FAIL_COUNT[$k]}"
    if [ "$v" -lt "$FAIL_THRESHOLD" ]; then
      printf '_%s=%s\n' "$k" "$v"
    elif [ -n "$seen" ] && grep -qxF "$k" "$seen"; then
      printf '_%s=%s\n' "$k" "$v"
    fi
  done | sort >> "$FAIL_COUNTS_FILE"
}
