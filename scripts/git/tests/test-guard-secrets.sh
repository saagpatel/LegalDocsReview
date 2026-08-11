#!/usr/bin/env bash
# Regression test for guard-secrets.sh.
#
# The guard's own logic is what varies between repos, so that is what this
# pins: whether a finding is refused, whether a clean scan passes, and what
# happens when the scanner is missing inside and outside CI.
#
# gitleaks is replaced by a stub whose exit code the test controls. That keeps
# the suite hermetic, independent of which gitleaks version is installed and
# of its rule set, and means no credential-shaped string needs to exist in
# this repository to test a secret scanner.
#
# Usage: bash scripts/git/tests/test-guard-secrets.sh
set -uo pipefail

GUARD="$(cd "$(dirname "$0")/.." && pwd)/guard-secrets.sh"
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

# run_guard <stub-exit|none> [ENV=VAL ...]
# stub-exit "none" removes gitleaks from PATH entirely.
run_guard() {
  local stub="$1"; shift
  local tmp rc
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/bin" "$tmp/repo"

  if [[ "$stub" != "none" ]]; then
    printf '#!/usr/bin/env bash\nexit %s\n' "$stub" > "$tmp/bin/gitleaks"
    chmod +x "$tmp/bin/gitleaks"
  fi

  (
    cd "$tmp/repo" || exit 1
    git init -b main . >/dev/null 2>&1
    git config user.email t@example.com
    git config user.name T
    echo content > file.txt
    git add file.txt >/dev/null

    env -u CI -u GITHUB_ACTIONS "PATH=$tmp/bin:/usr/bin:/bin" "$@" \
        bash "$GUARD" >/dev/null 2>&1
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

echo "guard-secrets regression tests"

echo "  -- with a scanner present --"
check "a finding is refused"                  REFUSED 1
check "a clean scan is allowed"               allowed 0

echo "  -- with no scanner --"
check "outside CI it fails closed"            REFUSED none
check "CI=true skips"                         allowed none CI=true
check "GITHUB_ACTIONS=true skips"             allowed none GITHUB_ACTIONS=true

# The escape hatch keys on the exact value "true", not on the variable merely
# being set. Every system that reaches this branch for real (GitHub Actions,
# GitLab CI) sets exactly "true", while a developer who exports CI for unrelated
# tooling, or anything that sets it to a falsey string, would otherwise turn the
# only local secret check off without meaning to.
echo "  -- the escape hatch needs the value, not just the variable --"
check "CI=1 does not skip"                    REFUSED none CI=1
check "CI=false does not skip"                REFUSED none CI=false
check "GITHUB_ACTIONS=false does not skip"    REFUSED none GITHUB_ACTIONS=false

echo "  -- the scanner still decides inside CI --"
check "finding in CI is still refused"        REFUSED 1 CI=true
check "clean scan in CI is allowed"           allowed 0 CI=true

echo
if (( failures )); then
  echo "$failures failing"
  exit 1
fi
echo "all passing"
