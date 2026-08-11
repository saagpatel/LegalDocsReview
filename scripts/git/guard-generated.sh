#!/usr/bin/env bash
set -euo pipefail

# codex-os-managed
forbidden='(^|/)(node_modules|dist|build|out|coverage|\.next|target)/'
# --diff-filter=d excludes deletions. Without it, staging the removal of build
# output that was committed by mistake trips this guard, so the only way to act
# on the message below is to bypass the hook that prints it.
if git diff --cached --name-only --diff-filter=d | grep -E "$forbidden" >/dev/null; then
  echo "Generated artifacts are staged. Unstage them before commit."
  exit 1
fi
