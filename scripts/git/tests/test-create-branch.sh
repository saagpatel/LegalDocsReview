#!/usr/bin/env bash
# Regression test for create-branch.sh.
#
# Pins validation, the bounded slug, branch reuse, and base resolution. The base
# matters most: the version this was promoted from hardcoded origin/master,
# which is correct in one repository and wrong in most of the portfolio.
#
# Usage: bash scripts/git/tests/test-create-branch.sh
set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/create-branch.sh"
failures=0

report() {
  local name="$1" want="$2" got="$3"
  if [[ "$got" == "$want" ]]; then
    printf '  PASS  %-46s (%s)\n' "$name" "$got"
  else
    printf '  FAIL  %-46s want=%s got=%s\n' "$name" "$want" "$got"
    failures=$((failures + 1))
  fi
}

# A repo whose default branch is named by the caller, so the master-vs-main
# question is exercised rather than assumed.
seed() {
  local tmp="$1" default="${2:-main}"
  git init -b "$default" "$tmp" >/dev/null 2>&1
  git -C "$tmp" config user.email t@example.com
  git -C "$tmp" config user.name T
  echo seed > "$tmp/README.md"
  git -C "$tmp" add README.md >/dev/null
  git -C "$tmp" commit -m seed >/dev/null
}

# Returns the branch actually checked out, or rc=<code> when the script refused.
landed() {
  local tmp="$1"; shift
  if (cd "$tmp" && bash "$SCRIPT" "$@" >/dev/null 2>&1); then
    git -C "$tmp" rev-parse --abbrev-ref HEAD
  else
    echo "rc=$?"
  fi
}

echo "create-branch regression tests"

tmp="$(mktemp -d)"; seed "$tmp"
report "a task becomes a slugged branch" "codex/feat/add-user-login" \
  "$(landed "$tmp" "Add User Login")"
rm -rf "$tmp"

tmp="$(mktemp -d)"; seed "$tmp"
report "the type is honoured" "codex/fix/null-pointer" \
  "$(landed "$tmp" "Null pointer" fix)"
rm -rf "$tmp"

tmp="$(mktemp -d)"; seed "$tmp"
report "an invalid type is refused" "rc=1" \
  "$(landed "$tmp" "Some task" banana)"
rm -rf "$tmp"

tmp="$(mktemp -d)"; seed "$tmp"
report "an empty task is refused" "rc=1" "$(landed "$tmp" "")"
rm -rf "$tmp"

# Punctuation-only input slugs to nothing. Without a check the branch would be
# codex/feat/ , which git refuses with a less obvious error.
tmp="$(mktemp -d)"; seed "$tmp"
report "a task that slugs to nothing is refused" "rc=1" \
  "$(landed "$tmp" "!!! ???")"
rm -rf "$tmp"

# A branch name is a path component, so an unbounded slug fails at checkout
# rather than at validation.
tmp="$(mktemp -d)"; seed "$tmp"
long="$(landed "$tmp" "$(printf 'averylongword %.0s' {1..20})")"
report "a long task still lands on a branch" "codex/feat" "${long%/*}"
# codex/feat/ is 11 characters, so the rest is the slug.
report "its slug is capped at 48 characters" "48" "$((${#long} - 11))"
rm -rf "$tmp"

# Resuming a task must not be a fatal error.
tmp="$(mktemp -d)"; seed "$tmp"
landed "$tmp" "Reuse me" >/dev/null
git -C "$tmp" checkout --quiet main
report "an existing branch is resumed, not refused" "codex/feat/reuse-me" \
  "$(landed "$tmp" "Reuse me")"
rm -rf "$tmp"

# Base resolution, both spellings. Hardcoding either name breaks half of these.
tmp="$(mktemp -d)"; seed "$tmp" main
report "branches from main when that is the default" "codex/feat/from-default" \
  "$(landed "$tmp" "From default")"
rm -rf "$tmp"

tmp="$(mktemp -d)"; seed "$tmp" master
report "branches from master when that is the default" "codex/feat/from-default" \
  "$(landed "$tmp" "From default")"
rm -rf "$tmp"

# An explicit base wins over resolution.
tmp="$(mktemp -d)"; seed "$tmp" main
git -C "$tmp" branch other >/dev/null
report "an explicit base is used" "codex/chore/explicit-base" \
  "$(landed "$tmp" "Explicit base" chore other)"
rm -rf "$tmp"

echo
if (( failures )); then
  echo "$failures failing"
  exit 1
fi
echo "all passing"
