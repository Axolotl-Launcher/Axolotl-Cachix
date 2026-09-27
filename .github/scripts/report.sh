#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/fail-counts.sh"
# The repository, cache and refs come from config.json.
source "$(dirname "$0")/config.sh"

read -ra systems <<< "$SYSTEMS"

begin_marker='<!-- BEGIN CACHED-COMMITS -->'
end_marker='<!-- END CACHED-COMMITS -->'

declare -A counts=()

load_failure_counts() {
  local system file sha
  for system in "${systems[@]}"; do
    file="${RUNNER_TEMP:-}/fail-counts-${system}.txt"
    [ -f "$file" ] || continue
    fail_counts_load_file "$file"
    for sha in "${!FAIL_COUNT[@]}"; do
      counts["${system}:${sha}"]="${FAIL_COUNT[$sha]}"
    done
  done
}

standing_refs() {
  local ref
  local -A seen=()
  unset INPUT_REF
  collect_refs
  for ref in "${REFS[@]}"; do
    [ -n "$ref" ] || continue
    [ -z "${seen[$ref]:-}" ] || continue
    seen["$ref"]=1
    printf '%s\n' "$ref"
  done
}

wrapper_drvs_json() {
  local expr="pkgs: {" system
  for system in "${systems[@]}"; do
    expr+=" \"${system}\" = pkgs.\"${system}\".${BUILD_ATTR}.drvPath or null;"
  done
  expr+=" }"
  nix eval --json --accept-flake-config --apply "$expr" \
    "${AXOLOTL_FLAKE}?rev=$1#packages" 2>/dev/null
}

cell_of() {
  local system="$1" sha="$2" json="$3" drv dep n
  drv="$(printf '%s' "$json" | jq -r --arg s "$system" '.[$s] // ""' 2>/dev/null || true)"
  if [ -z "$drv" ]; then
    printf '%s' ' 💤 |'
    return 0
  fi

  dep="$(axolotl_drv_in "$drv" || true)"
  if [ -z "$dep" ]; then
    printf '%s' ' 💤 |'
    return 0
  fi

  local -a outs=()
  mapfile -t outs < <(nix-store -q --outputs "$dep")
  if [ ${#outs[@]} -eq 0 ]; then
    printf '%s' ' 💤 |'
    return 0
  fi

  if nix path-info --store "${CACHE_STORE}" "${outs[@]}" >/dev/null 2>&1; then
    printf '%s' ' ✅ |'
    return 0
  fi

  n="${counts["${system}:${sha}"]:-0}"
  if [ "$n" -ge "$FAIL_THRESHOLD" ]; then
    printf '%s' ' ❌ |'
  elif [ "$n" -eq 2 ]; then
    printf '%s' ' ❓ |'
  elif [ "$n" -eq 1 ]; then
    printf '%s' ' ❔ |'
  else
    printf '%s' ' ⏳ |'
  fi
}

render_table() {
  local ref sha json commit_url line system
  local header="| Ref | Commit |"
  local separator="| --- | --- |"
  local rows=""

  for system in "${systems[@]}"; do
    header+=" ${system} |"
    separator+=" :---: |"
  done

  for ref in "$@"; do
    sha="$(sha_of "$ref")"
    if [ -z "$sha" ]; then
      line="| \`${ref}\` | — |"
      for system in "${systems[@]}"; do
        line+=" — |"
      done
      rows+="${line}"$'\n'
      continue
    fi

    json="$(wrapper_drvs_json "$sha")" || json=""
    commit_url="${AXOLOTL_REPO}/commit/${sha}"
    line="| \`${ref}\` | [\`${sha}\`](${commit_url}) |"
    for system in "${systems[@]}"; do
      line+="$(cell_of "$system" "$sha" "$json")"
    done
    rows+="${line}"$'\n'
  done

  printf '%s\n%s\n' "$header" "$separator"
  printf '%s' "$rows"
}

replace_table() {
  local updated
  if ! grep -qF "$begin_marker" README.md || ! grep -qF "$end_marker" README.md; then
    printf 'README.md is missing %s / %s\n' "$begin_marker" "$end_marker" >&2
    exit 1
  fi

  updated="$(mktemp)"
  {
    sed -n "1,/${begin_marker}/p" README.md
    printf '\n%s\n\n' "$1"
    sed -n "/${end_marker}/,\$p" README.md
  } > "$updated"
  cp "$updated" README.md
  rm -f "$updated"
}

main() {
  local -a refs=()
  local list table

  load_failure_counts
  list="$(standing_refs)"
  if [ -n "$list" ]; then
    mapfile -t refs <<< "$list"
  fi

  table="$(render_table "${refs[@]}")"
  replace_table "$table"
}

main
