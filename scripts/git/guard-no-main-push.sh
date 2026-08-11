#!/usr/bin/env bash
set -euo pipefail

# codex-os-managed
branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  echo "Pushing from $branch is blocked."
  exit 1
fi

# The check above only knows which branch you are standing on. It does not see
# where the push is going, so `git push origin feature:main` passes it while
# writing straight to the protected branch. Git hands a pre-push hook one line
# per ref on stdin, "<local ref> <local sha> <remote ref> <remote sha>", which
# is the only place the destination appears. Read it and refuse by destination.
#
# Skip the read entirely on a terminal. Run by hand as
# `pnpm git:guard:no-main-push`, an unguarded read would sit waiting for input
# that never comes, turning a guard into a hang. Outside a pre-push hook the
# branch check above is the whole guard, which is the pre-existing behaviour.
if [[ ! -t 0 ]]; then
  while IFS=' ' read -r _local_ref _local_sha remote_ref _remote_sha; do
    [[ -z "$remote_ref" ]] && continue
    if [[ "$remote_ref" =~ ^refs/heads/(main|master)$ ]]; then
      echo "Push to protected branch (${remote_ref#refs/heads/}) is blocked."
      exit 1
    fi
  done
fi
