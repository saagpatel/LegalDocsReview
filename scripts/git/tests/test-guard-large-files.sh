#!/usr/bin/env bash
# Regression test for guard-large-files.sh.
#
# Size is the easy half. The half that broke is path handling: git renders any
# path outside plain ASCII in quoted escaped form unless asked not to, and the
# guard then looked up a filename that does not exist.
#
# Usage: bash scripts/git/tests/test-guard-large-files.sh
set -uo pipefail

GUARD="$(cd "$(dirname "$0")/.." && pwd)/guard-large-files.sh"
failures=0

seed() {
  local tmp="$1"
  git init -b main "$tmp" >/dev/null 2>&1
  git -C "$tmp" config user.email t@example.com
  git -C "$tmp" config user.name T
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

# stage_one <filename> ; creates a 5-byte file with that exact name
small_case() {
  local name="$1" label="$2" want="$3"
  local tmp; tmp="$(mktemp -d)"
  seed "$tmp"
  printf 'tiny\n' > "$tmp/$name"
  git -C "$tmp" add -- "$name" >/dev/null 2>&1
  report "$label" "$want" "$(cd "$tmp" && verdict)"
  rm -rf "$tmp"
}

echo "guard-large-files regression tests"

# oversized content is refused
tmp="$(mktemp -d)"; seed "$tmp"
: > "$tmp/blob.bin"
dd if=/dev/zero of="$tmp/blob.bin" bs=1048576 count=3 >/dev/null 2>&1
git -C "$tmp" add blob.bin >/dev/null
report "3MB file is refused" REFUSED "$(cd "$tmp" && verdict)"
rm -rf "$tmp"

# small files pass regardless of how awkward the name is
small_case "small.txt"               "small ascii name is allowed"      allowed
small_case "a file with spaces.txt"  "name with spaces is allowed"      allowed
small_case "café-notes.txt"          "non-ascii name is allowed"        allowed
small_case "naïve—dash.txt"          "multibyte punctuation is allowed" allowed

# the limit is configurable and still enforced on an awkward name
tmp="$(mktemp -d)"; seed "$tmp"
printf 'aaaaaaaaaaaaaaaaaaaa\n' > "$tmp/café-big.txt"
git -C "$tmp" add -- "café-big.txt" >/dev/null
if (cd "$tmp" && GIT_GUARD_MAX_BYTES=5 bash "$GUARD" >/dev/null 2>&1); then
  got=allowed
else
  got=REFUSED
fi
report "non-ascii name over the limit is refused" REFUSED "$got"
rm -rf "$tmp"

echo
if (( failures )); then
  echo "$failures failing"
  exit 1
fi
echo "all passing"
