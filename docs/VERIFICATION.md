# Developer verification

Run commands from the repository root on a feature branch or disposable checkout. Use Node 22.12+ on the 22.x line, 24.x, or 26+ (the committed Vitest 5 lockfile engine), plus pnpm, then use `pnpm install --frozen-lockfile`. Native Tauri work additionally needs Rust and macOS/Xcode Command Line Tools. Frontend fixture tests need no AI credentials or provider runtime.

The package `prepare` script installs Husky hooks. When verifying in a shared worktree, use `pnpm install --frozen-lockfile --ignore-scripts` to avoid changing the shared Git hook configuration; run the repo-owned guards explicitly before committing. This also skips dependency lifecycle scripts, so report any missing native dependency build rather than treating the install as a native-app check.

## Focused and broader checks

```bash
pnpm exec vitest run src/components/analysis/RiskPanel.test.tsx
pnpm test
pnpm build
pnpm perf:bundle
pnpm perf:assets
```

Choose an existing test file under `src/` for the focused Vitest command. `pnpm build` performs TypeScript checking (`tsc -b`) before the Vite build. There is no separate ESLint script; Prettier is the configured formatter. `pnpm exec prettier --check path/to/changed-file.ts` checks a changed supported text file without rewriting it.

The authoritative automated command list is [`.codex/verify.commands`](../.codex/verify.commands): branch/atomic/generated/large-file/secret guards, Vitest, measured build, bundle report, and asset checks. It uses `npm run perf:build` for the same package script because the measurement wrapper invokes `npm_execpath` through Node; a native pnpm executable cannot be launched as JavaScript. Run the measured build before `pnpm perf:bundle`, which reads existing `dist/assets` and otherwise emits a zero-byte `source: none` report.

For backend changes, use `cargo test --locked --manifest-path src-tauri/Cargo.toml` and `cargo clippy --locked --manifest-path src-tauri/Cargo.toml -- -D warnings` on the supported native platform. A frontend build is not evidence of code signing, distribution, native IPC, or AI-provider behavior. Do not run release/cleanup scripts or configure API keys just to verify source guidance.

## Conditional UI checks

For changed visible behavior, run the focused component tests and frontend build, then use `pnpm dev --host 127.0.0.1` for a browser check with synthetic documents and mocked provider responses. Browser-only mode cannot exercise native PDF extraction or Tauri dialogs. A native/provider check needs its own approved disposable inputs and environment; never use private contracts as a fixture. Documentation-only changes do not require starting the application.

GitHub performance workflows and CodeQL remain additional hosted gates; local fixture checks do not replace them.
