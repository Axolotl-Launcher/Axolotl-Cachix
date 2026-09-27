#!/usr/bin/env bash
#
# Move the pnpm-deps of the current todo list in and out of the Actions cache:
#
#   import   copy them from the restored cache directory into the Nix store
#   export   copy whatever landed in the store into the directory the save step
#            uploads again — run even when a build failed, so the next run does
#            not have to refetch them
#
# Requires RUNNER_TEMP; reads $RUNNER_TEMP/pnpm-deps.txt.
set -euo pipefail

case "${1:-}" in
  import)
    while IFS= read -r p; do
      [ -z "$p" ] && continue
      echo "Importing ${p} from the Actions cache"
      nix copy --no-check-sigs --from "file://$RUNNER_TEMP/pnpm-deps-cache" "$p" || true
    done < "$RUNNER_TEMP/pnpm-deps.txt"
    ;;
  export)
    mkdir -p "$RUNNER_TEMP/pnpm-deps-cache"
    while IFS= read -r p; do
      [ -z "$p" ] && continue
      if nix path-info "$p" >/dev/null 2>&1; then
        echo "Exporting ${p} to the Actions cache"
        nix copy --to "file://$RUNNER_TEMP/pnpm-deps-cache?compression=none" "$p" || true
      fi
    done < "$RUNNER_TEMP/pnpm-deps.txt"
    ;;
  *)
    printf 'usage: %s import|export\n' "$0" >&2
    exit 2
    ;;
esac
