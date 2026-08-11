#!/usr/bin/env bash
set -euo pipefail

# codex-os-managed
max_bytes="${GIT_GUARD_MAX_BYTES:-2097152}"
fail=0
# -z emits NUL-separated paths verbatim. Without it git renders any path that
# is not plain ASCII in quoted escaped form, so a file named "café.txt" comes
# back as "caf\303\251.txt" and the cat-file lookup below fails with a fatal
# error. Under set -e that aborts the guard, and the commit is refused with a
# message about a path not existing rather than anything about file size.
while IFS= read -r -d '' file; do
  size=$(git cat-file -s ":$file")
  if (( size > max_bytes )); then
    echo "Large file staged (>${max_bytes} bytes): $file"
    fail=1
  fi
done < <(git diff --cached --name-only -z --diff-filter=AM)
exit $fail
