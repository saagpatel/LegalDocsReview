#!/usr/bin/env bash
set -euo pipefail

# codex-os-managed
tag="codex-wip/$(git rev-parse --abbrev-ref HEAD)/$(date +%Y%m%d-%H%M%S)"
marker_path="$(git rev-parse --git-path CODEX_LAST_WIP)"
git stash push -u -m "$tag"
echo "$tag" > "$marker_path"
echo "Saved WIP: $tag"
