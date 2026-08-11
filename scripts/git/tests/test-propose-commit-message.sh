#!/usr/bin/env bash
# Regression test for propose-commit-message.mjs.
#
# The proposal is advisory, so nothing breaks when it is wrong. What it costs is
# trust: a proposer that calls a source change "docs" gets ignored, and then it
# may as well not exist. These cases pin the classifications that were wrong
# before this script was promoted.
#
# Usage: bash scripts/git/tests/test-propose-commit-message.sh
set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/propose-commit-message.mjs"
failures=0

report() {
  local name="$1" want="$2" got="$3"
  if [[ "$got" == "$want" ]]; then
    printf '  PASS  %-46s (%s)\n' "$name" "$got"
  else
    printf '  FAIL  %-46s\n        want: %s\n        got:  %s\n' "$name" "$want" "$got"
    failures=$((failures + 1))
  fi
}

# propose <expected> <name> <path>...
propose() {
  local want="$1" name="$2"; shift 2
  local tmp got
  tmp="$(mktemp -d)"
  git init -b main "$tmp" >/dev/null 2>&1
  git -C "$tmp" config user.email t@example.com
  git -C "$tmp" config user.name T
  local p
  for p in "$@"; do
    mkdir -p "$tmp/$(dirname "$p")"
    echo x > "$tmp/$p"
    git -C "$tmp" add -f -- "$p" >/dev/null 2>&1
  done
  got="$(cd "$tmp" && node "$SCRIPT" 2>/dev/null | head -1)"
  [[ -n "$got" ]] || got="(no output)"
  report "$name" "$want" "$got"
  rm -rf "$tmp"
}

echo "propose-commit-message regression tests"

echo "  -- scope comes from the staged paths --"
propose "feat(src): update app.ts"            "a single source file is named"      src/app.ts
propose "feat(src): update 2 files for src changes" "several files report their scope" src/a.ts src/b.ts
propose "ci(github): update ci.yml"           "a leading dot is dropped from scope" .github/workflows/ci.yml

echo "  -- classification --"
propose "docs(docs): update guide.md"         "docs only is docs"                  docs/guide.md
propose "test(tests): update unit.test.ts"    "a .test. file is a test change"     tests/unit.test.ts
propose "perf(scripts): update bench.ts"      "a perf path is a perf change"       scripts/perf/bench.ts
propose "chore(repo): update package.json"       "a manifest is a chore"              package.json
propose "chore(repo): update Cargo.toml"         "a Rust manifest is a chore too"     Cargo.toml

echo "  -- classifications that were wrong before --"
# hasDocs used some(): one Markdown file alongside source made the whole commit
# a docs change.
propose "feat(src): update 2 files for src changes" \
  "source plus a note is not a docs change" src/app.ts src/NOTES.md
# hasTests matched the bare substring "test", so latest.ts was a test change.
propose "feat(src): update latest.ts"         "latest.ts is not a test file"       src/latest.ts
# hasDeps matched "lock" anywhere, so blocklist.ts was a dependency change.
propose "feat(src): update blocklist.ts"      "blocklist.ts is not a lockfile"     src/blocklist.ts

echo "  -- shape --"
propose "(no output)"                          "nothing staged produces nothing"

echo
if (( failures )); then
  echo "$failures failing"
  exit 1
fi
echo "all passing"
