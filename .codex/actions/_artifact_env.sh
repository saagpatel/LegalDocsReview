#!/usr/bin/env bash
set -euo pipefail

# codex-os-managed
REPO_ROOT="${CODEX_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
REPO_NAME="${CODEX_REPO_NAME:-$(basename "$REPO_ROOT")}" 

if command -v shasum >/dev/null 2>&1; then
  REPO_HASH="${CODEX_REPO_HASH:-$(printf '%s' "$REPO_ROOT" | shasum -a 256 | awk '{print substr($1,1,12)}')}"
else
  REPO_HASH="${CODEX_REPO_HASH:-$(printf '%s' "$REPO_ROOT" | md5 | awk '{print substr($NF,1,12)}')}"
fi

RUN_ID="${CODEX_RUN_ID:-$(date +%Y%m%dT%H%M%S)-$$}"
CODEX_CACHE_ROOT="${CODEX_CACHE_ROOT:-$HOME/Library/Caches/Codex}"
CODEX_BUILD_ROOT="${CODEX_BUILD_ROOT:-$CODEX_CACHE_ROOT/build}"
CODEX_LOG_ROOT="${CODEX_LOG_ROOT:-$CODEX_CACHE_ROOT/logs}"

export CODEX_REPO_ROOT="$REPO_ROOT"
export CODEX_REPO_NAME="$REPO_NAME"
export CODEX_REPO_HASH="$REPO_HASH"
export CODEX_RUN_ID="$RUN_ID"

export CODEX_BUILD_RUST_DIR="${CODEX_BUILD_RUST_DIR:-$CODEX_BUILD_ROOT/rust/$REPO_HASH}"
export CODEX_BUILD_NEXT_DIR="${CODEX_BUILD_NEXT_DIR:-$CODEX_BUILD_ROOT/next/$REPO_HASH}"
export CODEX_BUILD_JS_DIR="${CODEX_BUILD_JS_DIR:-$CODEX_BUILD_ROOT/js/$REPO_HASH}"
export CODEX_LOG_RUN_DIR="${CODEX_LOG_RUN_DIR:-$CODEX_LOG_ROOT/$REPO_NAME/$RUN_ID}"

mkdir -p "$CODEX_BUILD_RUST_DIR" "$CODEX_BUILD_NEXT_DIR" "$CODEX_BUILD_JS_DIR" "$CODEX_LOG_RUN_DIR"

if [[ -z "${CARGO_TARGET_DIR:-}" ]]; then
  export CARGO_TARGET_DIR="$CODEX_BUILD_RUST_DIR"
fi
if [[ -z "${NEXT_CACHE_DIR:-}" ]]; then
  export NEXT_CACHE_DIR="$CODEX_BUILD_NEXT_DIR"
fi
if [[ -z "${VITE_CACHE_DIR:-}" ]]; then
  export VITE_CACHE_DIR="$CODEX_BUILD_JS_DIR/vite"
fi
if [[ -z "${TURBO_CACHE_DIR:-}" ]]; then
  export TURBO_CACHE_DIR="$CODEX_BUILD_JS_DIR/turbo"
fi
