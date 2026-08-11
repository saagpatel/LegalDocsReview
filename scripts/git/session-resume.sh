#!/usr/bin/env bash
set -euo pipefail

# codex-os-managed
marker_path="$(git rev-parse --git-path CODEX_LAST_WIP)"
if [[ ! -f "$marker_path" ]]; then
  echo "No saved WIP tag found."
  exit 1
fi

tag="$(cat "$marker_path")"
git stash list | grep -F "$tag" >/dev/null
git stash apply "stash^{/$tag}"
echo "Restored WIP: $tag"
