#!/usr/bin/env bash
set -euo pipefail

# codex-os-managed
#
# Consolidated from the ten variants this script had drifted into across the
# portfolio. Every rule below already existed in at least one of them; none is
# new. scripts/git/tests/test-guard-branch.sh pins each one.
#
# Accepted branch shapes:
#   <type>/<slug>          fix/null-pointer
#   codex/<type>/<slug>    codex/fix/null-pointer
#   <agent>/<task-slug>    cc/rebuild-index, for peer agents

typed_pattern='^(codex/)?(feat|fix|chore|refactor|docs|test|perf|ci|spike|hotfix)/[a-z0-9]+(-[a-z0-9]+)*$'
peer_pattern='^(codex|cc)/[a-z0-9]+(-[a-z0-9]+)+$'

in_ci() { [[ "${CI:-}" == "true" || "${GITHUB_ACTIONS:-}" == "true" ]]; }

branch="$(git rev-parse --abbrev-ref HEAD)"

# A CI checkout is usually detached, so the real branch name lives in the event
# environment rather than in HEAD. GITHUB_REF_NAME also carries tag names, so
# it is trusted only when the ref really is a branch. Outside CI these
# variables are ignored entirely: a stray value in a local shell should not be
# able to talk this guard into approving a name that is not checked out.
if in_ci; then
  if [[ -n "${GITHUB_HEAD_REF:-}" ]]; then
    branch="$GITHUB_HEAD_REF"
  elif [[ "${GITHUB_REF_TYPE:-branch}" == "branch" && -n "${GITHUB_REF_NAME:-}" ]]; then
    branch="$GITHUB_REF_NAME"
  fi
fi

if [[ "$branch" == "HEAD" ]]; then
  if in_ci; then
    echo "Detached HEAD in CI; skipping branch-name enforcement."
    exit 0
  fi
  echo "Detached HEAD is not allowed for local development."
  echo "Check out a <type>/<slug> or codex/<type>/<slug> branch."
  exit 1
fi

if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  if in_ci; then
    echo "Protected branch $branch in a CI checkout; not local work."
    exit 0
  fi
  # A verification run against a clean checkout of the default branch is not
  # somebody editing main. At commit time something is always staged, so this
  # cannot excuse a real commit.
  if [[ -z "$(git status --porcelain)" ]]; then
    echo "Clean $branch checkout; no direct work detected."
    exit 0
  fi
  echo "Direct work on $branch is blocked."
  exit 1
fi

# Automation names its own branches and cannot rename them to fit a convention.
if [[ "$branch" == dependabot/* ]]; then
  echo "Dependabot automation branch; skipping branch-name enforcement."
  exit 0
fi

if [[ "$branch" == release-please--branches--* ]]; then
  echo "Release Please automation branch; skipping branch-name enforcement."
  exit 0
fi

if ! [[ "$branch" =~ $typed_pattern || "$branch" =~ $peer_pattern ]]; then
  echo "Invalid branch: $branch"
  echo "Expected: <type>/<slug>, codex/<type>/<slug>, or <agent>/<task-slug>"
  exit 1
fi
