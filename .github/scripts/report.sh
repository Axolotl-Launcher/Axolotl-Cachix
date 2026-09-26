#!/usr/bin/env bash
#
# Regenerate the "cached commits" table in README.md.
# Requires AXOLOTL_REPO, AXOLOTL_FLAKE, CACHE_STORE, DEFAULT_REFS, SYSTEMS,
# BUILD_ATTR, CACHIX_PUSH_PATTERN.
set -euo pipefail

source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/fail-counts.sh"

read -ra systems <<< "$SYSTEMS"

# Failure counts recorded by the cache job, keyed <system>:<sha>. They come from
# the actions/cache entries this job restores; a missing file only means no run
# has recorded a failure yet.
declare -A counts=()
for system in "${systems[@]}"; do
  file="${RUNNER_TEMP:-}/fail-counts-${system}.txt"
  [ -f "$file" ] || continue
  fail_counts_load_file "$file"
  for sha in "${!FAIL_COUNT[@]}"; do
    counts["${system}:${sha}"]="${FAIL_COUNT[$sha]}"
  done
done

# The wrapper derivation of every system for one commit, evaluated in a single
# pass: the flake is fetched once, and a system without the attribute comes back
# as null instead of failing the whole call.
wrapper_drvs_json() {
  local expr="pkgs: {" system
  for system in "${systems[@]}"; do
    expr+=" \"${system}\" = pkgs.\"${system}\".${BUILD_ATTR}.drvPath or null;"
  done
  expr+=" }"
  nix eval --json --accept-flake-config --apply "$expr" \
    "${AXOLOTL_FLAKE}?rev=$1#packages" 2>/dev/null
}

# One table cell: what the cache holds for this commit on this system. A miss
# reports how many times the cache job has already failed to build it: nothing
# recorded yet (the build itself worked but never reached the cache), one or two
# failures, or FAIL_THRESHOLD and therefore skipped on the next run.
cell_of() {
  local system="$1" sha="$2" json="$3" drv dep n
  drv="$(printf '%s' "$json" | jq -r --arg s "$system" '.[$s] // ""' 2>/dev/null || true)"
  if [ -z "$drv" ]; then
    printf '%s' ' — |'
    return 0
  fi

  dep="$(axolotl_drv_in "$drv" || true)"
  if [ -z "$dep" ]; then
    printf '%s' ' — |'
    return 0
  fi

  local -a outs=()
  mapfile -t outs < <(nix-store -q --outputs "$dep")
  if [ ${#outs[@]} -eq 0 ]; then
    printf '%s' ' — |'
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

# The report always reflects the standing set of refs, never a manual INPUT_REF.
unset INPUT_REF
collect_refs

refs=()
for ref in "${REFS[@]}"; do
  [ -z "$ref" ] && continue
  dup=0
  for seen in "${refs[@]}"; do
    [ "$seen" = "$ref" ] && dup=1 && break
  done
  [ "$dup" -eq 0 ] && refs+=("$ref")
done

header="| Ref | Commit |"
separator="| --- | --- |"
for system in "${systems[@]}"; do
  header+=" ${system} |"
  separator+=" :---: |"
done

rows=""
json=""
for ref in "${refs[@]}"; do
  sha="$(sha_of "$ref")"
  if [ -z "$sha" ]; then
    line="| \`${ref}\` | — |"
    for _ in "${systems[@]}"; do line+=" — |"; done
    rows+="${line}"$'\n'
    continue
  fi

  json="$(wrapper_drvs_json "$sha")" || json=""
  commit_url="${AXOLOTL_REPO}/commit/${sha}"
  # The full hash, not an abbreviation: `rev=` in a flake reference needs all 40
  # characters, and this table is where they get copied from.
  line="| \`${ref}\` | [\`${sha}\`](${commit_url}) |"
  for system in "${systems[@]}"; do
    line+="$(cell_of "$system" "$sha" "$json")"
  done
  rows+="${line}"$'\n'
done

block="$(mktemp)"
{
  echo '<!-- BEGIN CACHED-COMMITS -->'
  echo
  echo "$header"
  echo "$separator"
  printf '%s' "$rows"
  echo
  echo "Legend: \`✅\` in the cache · \`⏳\` built but never cached · \`❔\`/\`❓\` 1/2 recorded build failures · \`❌\` ${FAIL_THRESHOLD}+ recorded build failures, skipped · \`—\` derivation could not be resolved"
  echo
  echo '<!-- END CACHED-COMMITS -->'
} > "$block"

if [ ! -f README.md ]; then
  {
    echo "# Axolotl-Cachix"
    echo
    echo "Prebuilt [Axolotl](${AXOLOTL_REPO}) artifacts are pushed to the"
    echo "\`${CACHE_STORE}\` Cachix cache. The table below is updated automatically."
    echo
  } > README.md
fi

if ! grep -q '<!-- BEGIN CACHED-COMMITS' README.md; then
  printf '\n' >> README.md
  cat "$block" >> README.md
  rm -f "$block"
  exit 0
fi

tmp="$(mktemp)"
awk -v block="$block" '
  /<!-- BEGIN CACHED-COMMITS/ { while ((getline line < block) > 0) print line; skip=1; next }
  /<!-- END CACHED-COMMITS/ { skip=0; next }
  !skip { print }
' README.md > "$tmp"
mv "$tmp" README.md
rm -f "$block"
