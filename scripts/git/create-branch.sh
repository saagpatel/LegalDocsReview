#!/usr/bin/env bash
set -euo pipefail

# codex-os-managed
#
# Promoted from AssistSupport, which was the only repository whose version
# validated the branch type, bounded the slug, and reused an existing branch
# instead of failing. The one thing changed on the way up is the base: that
# version hardcoded origin/master, which is right for AssistSupport and wrong
# for most of the portfolio, so the default branch is resolved instead.
#
# Usage: create-branch.sh "task summary" [type] [base]

task="${1:-}"
kind="${2:-feat}"
base="${3:-}"

types='feat|fix|chore|refactor|docs|test|perf|ci|spike|hotfix'

if [[ -z "$task" ]]; then
  echo "Usage: $0 \"task summary\" [${types//|/|}] [base]"
  exit 1
fi

if ! [[ "$kind" =~ ^($types)$ ]]; then
  echo "Invalid branch type: $kind"
  echo "Expected one of: ${types//|/, }"
  exit 1
fi

# Resolve the base branch rather than assuming a name. origin/HEAD is the
# repository's own answer; the named fallbacks cover a clone that never fetched
# it, and the final fallback is the current commit, which always exists.
resolve_base() {
  local ref
  if ref="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)"; then
    echo "$ref"
    return
  fi
  for ref in origin/main origin/master main master; do
    if git rev-parse --verify --quiet "$ref" >/dev/null; then
      echo "$ref"
      return
    fi
  done
  echo "HEAD"
}

# A branch name is a path, so an unbounded slug can exceed the filesystem's
# limit on a single component and fail at checkout rather than at validation.
slug="$(echo "$task" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g')"
slug="${slug:0:48}"
slug="${slug%-}"

if [[ -z "$slug" ]]; then
  echo "Task summary produced an empty slug: $task"
  exit 1
fi

branch="codex/${kind}/${slug}"

git fetch origin --quiet 2>/dev/null || true
[[ -n "$base" ]] || base="$(resolve_base)"

# Reusing the branch when it already exists is the difference between resuming
# a task and getting a fatal error partway through one.
if git show-ref --verify --quiet "refs/heads/$branch"; then
  git checkout --quiet "$branch"
  echo "Resumed branch: $branch"
else
  git checkout --quiet -b "$branch" "$base"
  echo "Created branch: $branch (from $base)"
fi
