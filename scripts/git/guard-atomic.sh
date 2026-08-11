#!/usr/bin/env bash
set -euo pipefail

# codex-os-managed
#
# An intentional exception has to be expressible. Without one, the only way past
# this guard is to bypass the hook that runs it, which switches off the branch,
# generated-file, large-file and secret guards at the same time. AssistSupport
# was the only repository in the portfolio carrying this escape hatch.
if [[ "${GIT_GUARD_ALLOW_LARGE_COMMIT:-0}" == "1" ]]; then
  echo "Atomicity check skipped: GIT_GUARD_ALLOW_LARGE_COMMIT=1."
  exit 0
fi

max_files="${GIT_GUARD_MAX_FILES:-25}"
count="$(git diff --cached --name-only | sed '/^$/d' | wc -l | tr -d ' ')"

if ((count == 0)); then
  echo "No staged files; skipping atomicity check."
  exit 0
fi

# Deletions are counted deliberately. Removing forty files is a large commit
# whichever direction the change runs, and the escape hatch above is how to say
# that it is intentional.
if ((count > max_files)); then
  echo "Too many staged files ($count > $max_files). Split into atomic commits."
  echo "For a deliberately large commit, set GIT_GUARD_ALLOW_LARGE_COMMIT=1."
  exit 1
fi
