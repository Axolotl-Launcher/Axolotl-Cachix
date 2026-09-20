#!/usr/bin/env bash
#
# Regenerate the "cached commits" table in README.md.
# Requires AXOLOTL_REPO, AXOLOTL_FLAKE, CACHE_STORE, DEFAULT_REFS, SYSTEMS.
set -euo pipefail

source "$(dirname "$0")/common.sh"

read -ra systems <<< "$SYSTEMS"

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
for ref in "${refs[@]}"; do
  sha="$(sha_of "$ref")"
  if [ -z "$sha" ]; then
    line="| \`${ref}\` | — |"
    for _ in "${systems[@]}"; do line+=" — |"; done
    rows+="${line}"$'\n'
    continue
  fi

  commit_url="${AXOLOTL_REPO}/commit/${sha}"
  line="| \`${ref}\` | [\`${sha:0:12}\`](${commit_url}) |"
  for system in "${systems[@]}"; do
    if ! out="$(nix eval --raw --accept-flake-config "${AXOLOTL_FLAKE}?rev=${sha}#packages.${system}.default.outPath" 2>/dev/null)"; then
      line+=" — |"
    elif nix path-info --store "${CACHE_STORE}" "$out" >/dev/null 2>&1; then
      line+=" ✅ |"
    else
      line+=" ❌ |"
    fi
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
