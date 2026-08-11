#!/usr/bin/env bash
# Regression test for guard-no-main-push.sh.
#
# The guard originally checked only which branch you were standing on, so
# `git push origin feature:main` passed it while writing straight to the
# protected branch. This drives real pushes through a throwaway repo to prove
# the destination is now what gets refused.
#
# Usage: bash scripts/git/tests/test-guard-no-main-push.sh
set -uo pipefail

GUARD="$(cd "$(dirname "$0")/.." && pwd)/guard-no-main-push.sh"
failures=0

# Build a bare "origin" plus a clone whose pre-push hook is the guard, with a
# feature branch checked out and one commit ahead.
build() {
  local tmp="$1"
  git init --bare -b main "$tmp/origin.git" >/dev/null 2>&1
  git clone "$tmp/origin.git" "$tmp/work" >/dev/null 2>&1

  git -C "$tmp/work" config user.email t@example.com
  git -C "$tmp/work" config user.name T

  echo seed > "$tmp/work/README.md"
  git -C "$tmp/work" add README.md >/dev/null
  git -C "$tmp/work" commit -m seed >/dev/null
  git -C "$tmp/work" push origin main >/dev/null 2>&1

  # husky invokes the guard through a wrapper; stdin must pass straight through
  printf '#!/usr/bin/env bash\nexec bash %q "$@"\n' "$GUARD" \
    > "$tmp/work/.git/hooks/pre-push"
  chmod +x "$tmp/work/.git/hooks/pre-push"

  git -C "$tmp/work" checkout -b feature >/dev/null 2>&1
  echo x > "$tmp/work/f.txt"
  git -C "$tmp/work" add f.txt >/dev/null
  git -C "$tmp/work" commit -m feat >/dev/null
}

# check <name> <expected BLOCK|ALLOW> <checkout-first> <push args...>
check() {
  local name="$1" want="$2" checkout="$3"; shift 3
  local tmp got
  tmp="$(mktemp -d)"
  build "$tmp"
  [[ -n "$checkout" ]] && git -C "$tmp/work" checkout "$checkout" >/dev/null 2>&1

  if git -C "$tmp/work" push "$@" >/dev/null 2>&1; then got=ALLOW; else got=BLOCK; fi
  rm -rf "$tmp"

  if [[ "$got" == "$want" ]]; then
    printf '  PASS  %-38s (%s)\n' "$name" "$got"
  else
    printf '  FAIL  %-38s want=%s got=%s\n' "$name" "$want" "$got"
    failures=$((failures + 1))
  fi
}

echo "guard-no-main-push regression tests"
check "feature -> main is refused"    BLOCK ""     origin feature:main
check "feature -> feature is allowed" ALLOW ""     origin feature:feature
check "pushing while on main refused" BLOCK main   origin main

# Run by hand with no push payload the guard must exit cleanly rather than
# block on a read that never receives input.
#
# This runs inside a throwaway repo on a feature branch, never in this
# checkout. Run here it would inherit whatever branch the checkout is on, and
# on main the guard correctly refuses, so the case would fail on main and pass
# everywhere else. That is a property of the checkout, not of the guard.
hand_run() {
  local branch="$1" tmp rc
  tmp="$(mktemp -d)"
  build "$tmp"
  git -C "$tmp/work" checkout "$branch" >/dev/null 2>&1
  ( cd "$tmp/work" && timeout 10 bash "$GUARD" < /dev/null >/dev/null 2>&1 )
  rc=$?
  rm -rf "$tmp"
  return $rc
}

if hand_run feature; then
  printf '  PASS  %-38s (exit 0)\n' "hand-run on a feature branch"
else
  printf '  FAIL  %-38s hung or exited non-zero\n' "hand-run on a feature branch"
  failures=$((failures + 1))
fi

# Standing on main with no push payload, the original branch check still fires.
if hand_run main; then
  printf '  FAIL  %-38s want refusal, got exit 0\n' "hand-run while on main"
  failures=$((failures + 1))
else
  printf '  PASS  %-38s (refused)\n' "hand-run while on main"
fi

echo
if (( failures )); then
  echo "$failures failing"
  exit 1
fi
echo "all passing"
