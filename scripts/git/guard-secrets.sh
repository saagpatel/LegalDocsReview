#!/usr/bin/env bash
set -euo pipefail

# codex-os-managed
if ! command -v gitleaks >/dev/null 2>&1; then
  # Three repositories reach this branch for real: their CI runs this guard
  # through the verify bundle on a runner that never installs gitleaks, so
  # refusing here would fail every pull request without scanning anything.
  # Everywhere else the bundle is CI-gated or its calling workflow never runs,
  # so this branch costs nothing. Both variable spellings are accepted because
  # different repos in the portfolio checked different ones.
  #
  # The value is checked, not merely the variable's presence. Every system that
  # reaches this branch for real sets exactly "true" (GitHub Actions, and GitLab
  # for the one repo that has a pipeline). Testing presence instead would let
  # CI=false, or a developer who exports CI for unrelated tooling, silently turn
  # off the only secret check a local commit gets.
  if [[ "${CI:-}" == "true" || "${GITHUB_ACTIONS:-}" == "true" ]]; then
    echo "gitleaks not found in this CI job; skipping the local secret guard."
    # Deliberately not claiming CI scanning covers this. In much of the
    # portfolio the gitleaks workflow triggers on pull_request only, so a
    # direct push to the default branch is scanned by nothing at all.
    echo "Secret scanning in CI belongs to the git-hygiene workflow; confirm it runs on this event."
    exit 0
  fi
  # Outside CI, refuse. A missing scanner is not a clean scan, and this hook is
  # the only secret check a commit reaches when it never becomes a pull request.
  echo "gitleaks not found. Install gitleaks to enforce secret scanning."
  exit 1
fi

gitleaks protect --staged --redact
