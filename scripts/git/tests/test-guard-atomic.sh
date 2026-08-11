#!/usr/bin/env bash
# Regression test for guard-atomic.sh.
#
# Pins the limit, that deletions count toward it, and the intentional-exception
# escape hatch that was promoted here from AssistSupport.
#
# Usage: bash scripts/git/tests/test-guard-atomic.sh
set -uo pipefail

GUARD="$(cd "$(dirname "$0")/.." && pwd)/guard-atomic.sh"
failures=0

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

stage_files() {
  local tmp="$1" n="$2" i
  for ((i = 0; i < n; i++)); do echo x > "$tmp/f$i.txt"; done
  git -C "$tmp" add -A >/dev/null
}

echo "guard-atomic regression tests"

tmp="$(mktemp -d)"; seed "$tmp"; stage_files "$tmp" 10
report "10 staged files are allowed" allowed "$(cd "$tmp" && verdict)"
rm -rf "$tmp"

tmp="$(mktemp -d)"; seed "$tmp"; stage_files "$tmp" 25
report "exactly the limit is allowed" allowed "$(cd "$tmp" && verdict)"
rm -rf "$tmp"

tmp="$(mktemp -d)"; seed "$tmp"; stage_files "$tmp" 26
report "one over the limit is refused" REFUSED "$(cd "$tmp" && verdict)"
rm -rf "$tmp"

tmp="$(mktemp -d)"; seed "$tmp"
report "nothing staged is allowed" allowed "$(cd "$tmp" && verdict)"
rm -rf "$tmp"

tmp="$(mktemp -d)"; seed "$tmp"; stage_files "$tmp" 40
report "a raised limit is honoured" allowed \
  "$(cd "$tmp" && GIT_GUARD_MAX_FILES=50 verdict)"
rm -rf "$tmp"

# The escape hatch is the whole point of this promotion: without it the only
# way past the guard is to bypass the hook, which disables four other guards.
tmp="$(mktemp -d)"; seed "$tmp"; stage_files "$tmp" 40
report "the escape hatch allows a large commit" allowed \
  "$(cd "$tmp" && GIT_GUARD_ALLOW_LARGE_COMMIT=1 verdict)"
rm -rf "$tmp"

tmp="$(mktemp -d)"; seed "$tmp"; stage_files "$tmp" 40
report "any other hatch value does not excuse it" REFUSED \
  "$(cd "$tmp" && GIT_GUARD_ALLOW_LARGE_COMMIT=0 verdict)"
rm -rf "$tmp"

# Deletions count. Removing forty files is a large commit in either direction,
# and the hatch above is how to say it was deliberate.
tmp="$(mktemp -d)"; seed "$tmp"; stage_files "$tmp" 40
git -C "$tmp" commit -m bulk >/dev/null
(cd "$tmp" && rm -f f*.txt)
git -C "$tmp" add -A >/dev/null
report "40 staged deletions are refused" REFUSED "$(cd "$tmp" && verdict)"
rm -rf "$tmp"

echo
if (( failures )); then
  echo "$failures failing"
  exit 1
fi
echo "all passing"
