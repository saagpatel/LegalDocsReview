#!/usr/bin/env bash
# Regression test for guard-branch.sh.
#
# This guard had drifted into ten variants across the portfolio, each repo
# solving a different real problem locally. The consolidated version accepts
# every shape those variants accepted; this pins each one so the next
# divergence fails here instead of in fifty working copies.
#
# Usage: bash scripts/git/tests/test-guard-branch.sh
set -uo pipefail

GUARD="$(cd "$(dirname "$0")/.." && pwd)/guard-branch.sh"
failures=0

report() {
  local name="$1" want="$2" got="$3"
  if [[ "$got" == "$want" ]]; then
    printf '  PASS  %-44s (%s)\n' "$name" "$got"
  else
    printf '  FAIL  %-44s want=%s got=%s\n' "$name" "$want" "$got"
    failures=$((failures + 1))
  fi
}

# run <branch|--detached> [--dirty] [ENV=VAL ...]
run_guard() {
  local branch="$1"; shift
  local dirty=false
  if [[ "${1:-}" == "--dirty" ]]; then dirty=true; shift; fi

  local tmp rc
  tmp="$(mktemp -d)"
  (
    cd "$tmp" || exit 1
    git init -b main . >/dev/null 2>&1
    git config user.email t@example.com
    git config user.name T
    echo seed > README.md
    git add README.md >/dev/null
    git commit -m seed >/dev/null

    if [[ "$branch" == "--detached" ]]; then
      git checkout --detach >/dev/null 2>&1
    elif [[ "$branch" != "main" ]]; then
      # A name git refuses leaves the checkout on main, and the case then
      # quietly tests the default branch instead of what it claims to. Exit 99
      # so that shows up as a failure rather than a pass.
      git checkout -b "$branch" >/dev/null 2>&1 || exit 99
      [[ "$(git rev-parse --abbrev-ref HEAD)" == "$branch" ]] || exit 99
    fi

    if $dirty; then
      echo change >> README.md
      git add README.md >/dev/null
    fi

    # CI variables are only honoured when the guard believes it is in CI, so
    # each case passes exactly the environment it means to test.
    env -u CI -u GITHUB_ACTIONS -u GITHUB_HEAD_REF -u GITHUB_REF_NAME \
        -u GITHUB_REF_TYPE "$@" bash "$GUARD" >/dev/null 2>&1
  )
  rc=$?
  rm -rf "$tmp"
  return $rc
}

check() {
  local name="$1" want="$2"; shift 2
  local got
  if run_guard "$@"; then got=allowed; else got=REFUSED; fi
  report "$name" "$want" "$got"
}

echo "guard-branch regression tests"

echo "  -- accepted shapes --"
check "codex/<type>/<slug>"          allowed codex/fix/null-pointer
check "<type>/<slug>, no prefix"     allowed fix/null-pointer
check "peer agent cc/<task-slug>"    allowed cc/rebuild-index
check "peer agent codex/<task-slug>" allowed codex/rebuild-index

echo "  -- rejected shapes --"
check "unknown type"                 REFUSED feature/some-thing
check "uppercase in slug"            REFUSED codex/feat/BadSlug
check "bare word, no slash"          REFUSED wip
check "underscore in slug"           REFUSED codex/fix/has_underscore
check "unknown type under codex/"    REFUSED codex/badtype/slug
check "peer name without a hyphen"   REFUSED cc/single

echo "  -- the default branch --"
check "main with staged work"        REFUSED main --dirty
check "main clean is a verify run"   allowed main
check "main inside CI"               allowed main --dirty CI=true
check "main inside GitHub Actions"   allowed main --dirty GITHUB_ACTIONS=true

echo "  -- automation branches --"
check "dependabot branch"            allowed dependabot/npm_and_yarn/left-pad-1.2.3
check "dependabot branch in CI"      allowed dependabot/npm_and_yarn/left-pad-1.2.3 CI=true
check "release-please branch"        allowed release-please--branches--main

echo "  -- detached HEAD --"
check "detached locally is refused"  REFUSED --detached
check "detached in CI is skipped"    allowed --detached CI=true

echo "  -- CI resolves the name from the event --"
check "valid GITHUB_HEAD_REF"        allowed --detached CI=true GITHUB_HEAD_REF=codex/fix/from-event
check "invalid GITHUB_HEAD_REF"      REFUSED --detached CI=true GITHUB_HEAD_REF=feature/from-event
check "valid GITHUB_REF_NAME"        allowed --detached CI=true GITHUB_REF_NAME=fix/from-ref
check "a tag ref is not a branch"    allowed --detached CI=true GITHUB_REF_TYPE=tag GITHUB_REF_NAME=v1.2.3
check "env is ignored outside CI"    REFUSED --detached GITHUB_HEAD_REF=codex/fix/from-event

echo
if (( failures )); then
  echo "$failures failing"
  exit 1
fi
echo "all passing"
