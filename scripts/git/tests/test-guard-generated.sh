#!/usr/bin/env bash
# Regression test for guard-generated.sh.
#
# The guard refuses staged build output. It must not refuse the removal of
# build output that was committed by mistake, which is the one action its own
# error message asks for.
#
# Usage: bash scripts/git/tests/test-guard-generated.sh
set -uo pipefail

GUARD="$(cd "$(dirname "$0")/.." && pwd)/guard-generated.sh"
failures=0

# A global ignore file commonly lists dist/, so every add here uses -f. Without
# it the add silently stages nothing and the guard looks like it passed.
seed() {
  local tmp="$1"
  git init -b main "$tmp" >/dev/null 2>&1
  git -C "$tmp" config user.email t@example.com
  git -C "$tmp" config user.name T
  echo seed > "$tmp/README.md"
  git -C "$tmp" add README.md >/dev/null
  git -C "$tmp" commit -m seed >/dev/null
}

report() {
  local name="$1" want="$2" got="$3"
  if [[ "$got" == "$want" ]]; then
    printf '  PASS  %-46s (%s)\n' "$name" "$got"
  else
    printf '  FAIL  %-46s want=%s got=%s\n' "$name" "$want" "$got"
    failures=$((failures + 1))
  fi
}

verdict() { if bash "$GUARD" >/dev/null 2>&1; then echo allowed; else echo REFUSED; fi; }

echo "guard-generated regression tests"

# staging build output is refused
tmp="$(mktemp -d)"; seed "$tmp"
mkdir -p "$tmp/dist"; echo built > "$tmp/dist/app.js"
git -C "$tmp" add -f dist/app.js >/dev/null
report "staging dist/ is refused" REFUSED "$(cd "$tmp" && verdict)"
rm -rf "$tmp"

# ordinary source is untouched
tmp="$(mktemp -d)"; seed "$tmp"
echo source > "$tmp/src.js"
git -C "$tmp" add src.js >/dev/null
report "ordinary source is allowed" allowed "$(cd "$tmp" && verdict)"
rm -rf "$tmp"

# removing previously committed build output must be allowed
tmp="$(mktemp -d)"; seed "$tmp"
mkdir -p "$tmp/dist"; echo built > "$tmp/dist/app.js"
git -C "$tmp" add -f dist/app.js >/dev/null
git -C "$tmp" commit -m "committed build output by mistake" >/dev/null
git -C "$tmp" rm -r --cached dist >/dev/null
report "removing committed dist/ is allowed" allowed "$(cd "$tmp" && verdict)"
rm -rf "$tmp"

# a modification to build output still counts as staging it
tmp="$(mktemp -d)"; seed "$tmp"
mkdir -p "$tmp/dist"; echo built > "$tmp/dist/app.js"
git -C "$tmp" add -f dist/app.js >/dev/null
git -C "$tmp" commit -m "build output" >/dev/null
echo rebuilt > "$tmp/dist/app.js"
git -C "$tmp" add -f dist/app.js >/dev/null
report "modifying tracked dist/ is refused" REFUSED "$(cd "$tmp" && verdict)"
rm -rf "$tmp"

echo
if (( failures )); then
  echo "$failures failing"
  exit 1
fi
echo "all passing"
