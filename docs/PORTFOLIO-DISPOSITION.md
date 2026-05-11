# LegalDocsReview — Portfolio Disposition

**Status:** Release Frozen — Tauri 2 + Rust + React legal document review
desktop app on `origin/main` with all sprints (2-6) shipped: AI
integration (Claude / OpenAI / Ollama), risk scoring, document
comparison, templates, and reports. Joins the signing cluster as the
13th member.

> Disposition uses strict `origin/main` verification.

---

## Verification posture

This repo has both `origin` (`saagpatel/LegalDocsReview`) and
`legacy-origin` (`saagar210/LegalDocsReview`) remotes. **Local clone's
`main` was tracking `legacy-origin/main`** — same trap as FreeLanceInvoice
/ PersonalKBDrafter / BattleGrid / PomGambler. Fixed during this
disposition pass with `git branch --set-upstream-to=origin/main main`.

Specifically verified on `origin/main`:

- Tip: `7a913db` chore: add pull request template
- Substantive commits on `origin/main`:
  - `343589f` feat: implement all sprints (2-6) — AI integration, risk scoring, comparison, templates, reports
  - `d5ce51b` feat: initialize Legal Document Review Assistant (Sprint 1)
  - `21aad12` feat(dev): add lean mode and cleanup workflows
- Tree on `origin/main` is a full Tauri 2 desktop app:
  - `src-tauri/src/ai/{claude,ollama,openai,provider,prompts,types}.rs`
  - `src-tauri/src/analysis/{mod,risk_rules}.rs`
  - `src-tauri/src/commands/{analysis,comparison,document,report,settings,template}_commands.rs`
  - `src-tauri/src/db/{comparisons,documents,extractions,migrations}.rs`
- Release scaffolding: none yet (no `RELEASE-READINESS.md`,
  no `release-smoke.yml`)
- Default branch: `main`

---

## Legacy-origin orphan note

`legacy-origin/main` has 3 commits not on `origin/main` — all
`chore(codex): bootstrap tests and docs defaults`. Low value, safe to
ignore.

Lower stakes than FreeLanceInvoice's Stripe orphan. Operator should
review before considering them lost, but they're not load-bearing.

---

## Local working tree note

Local working tree had **significant uncommitted WIP** during this
pass — release-readiness workflow files (`desktop-release.yml`,
`quality-gates.yml`, `release-readiness.yml`, `security-scorecard.yml`,
`test-flake-diagnostics.yml`), tests directory, smoke scripts, and
mods to most src-tauri command files, src/pages, and configs. This
WIP is **not on `origin/main`** and is preserved in a git stash
(`r8-legaldocsreview-stash`) created during this disposition pass.

The operator should review the stash before the next session — it
contains real release-readiness scaffolding that may belong on
`origin/main`.

---

## Current state in one paragraph

Legal Document Review Assistant is a Tauri 2 + React + Vite + SQLite
desktop app for legal document review. AI integration spans Claude,
OpenAI, and local Ollama via a provider abstraction. Features per
`origin/main`: risk scoring driven by `risk_rules.rs`, document
comparison (both file-level and section-level), template management,
report generation, and structured document/extraction storage in
SQLite via `rusqlite`. All sprints 2-6 are shipped on canonical main.

For full detail see `README.md` on `origin/main`.

---

## Why "Release Frozen" instead of other dispositions

- **Active** — wrong. The product surface (all sprints 2-6) is
  complete; the gate is signing, not feature delivery. Note the
  uncommitted WIP, however — operator may want to land release-
  readiness scaffolding before signing.
- **Cold Storage / Archived** — wrong. The product is real and
  recent.
- **Release Frozen** — correct, with the asterisk that meaningful
  WIP exists locally.

This is the **13th signing cluster member**: DesktopPEt / ContentEngine
/ AIGCCore / Relay / FreeLanceInvoice / Nexus / DeepTank / OPscinema /
ShipKit / SignalFlow / PixelForge / DatabaseSchema / **LegalDocsReview**.

---

## Unblock trigger (operator)

When ready to ship:

1. **Review the local stash first.** The release-readiness workflow
   files in `r8-legaldocsreview-stash` may belong on `origin/main`
   before signing. Either land them via a separate PR or document
   why they're being abandoned.
2. Wire Apple Developer ID + notarization credentials.
3. Decide AI provider posture for the v1 release: bundle Ollama models
   (large .app), require operator-supplied API keys (Claude / OpenAI),
   or both. **This is product-decision territory analogous to
   PixelForge's model distribution question.**
4. Cut v1.0.0 release tag.
5. Verify signed/notarized DMG opens cleanly with no Gatekeeper
   warnings.

Estimated operator time once credentials are in hand: ~4 hours
including WIP stash review, notarization round-trip, and AI provider
decision.

---

## Portfolio operating system instructions

| Aspect               | Posture                                                                                                                                                                                                        |
| -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Portfolio status     | `Release Frozen`                                                                                                                                                                                               |
| Review cadence       | Suspend overdue counting                                                                                                                                                                                       |
| Resurface conditions | (a) Apple signing credentials wired, (b) operator picks AI provider distribution strategy, (c) operator decides what to do with stashed release-readiness WIP, or (d) operator opens a v1.1 scope packet       |
| Co-batch with        | Signing cluster: DesktopPEt / ContentEngine / AIGCCore / Relay / FreeLanceInvoice / Nexus / DeepTank / OPscinema / ShipKit / SignalFlow / PixelForge / DatabaseSchema / **LegalDocsReview** — **now 13 repos** |
| Special concern      | **Uncommitted release-readiness WIP in local stash.** Don't lose it.                                                                                                                                           |
| Special concern      | **AI provider strategy.** Similar shape to PixelForge's model question — bundled vs first-run vs operator-keys.                                                                                                |

---

## Why this row has two extra concerns

Most signing-cluster repos have a clean "sign + tag + release" unblock.
LegalDocsReview adds two:

1. **Stash to reconcile.** Real release-readiness work is sitting in
   the local working tree, not yet on `origin/main`. The disposition
   pass stashed it; the operator must decide what to do with it.
2. **AI provider strategy.** Like PixelForge but different. PixelForge
   bundles AI models (Phase 4 ML operations). LegalDocsReview uses AI
   providers as services — Claude API, OpenAI API, or local Ollama.
   The release decision is whether to bundle Ollama models, require
   API keys, or both.

Both should be resolved before signing.

---

## Reactivation procedure (for the next code session)

1. **Verify local clone tracking.** Confirm `main` tracks `origin/main`,
   not `legacy-origin/main`. Fixed during this pass.
2. `git stash list` — find `r8-legaldocsreview-stash` and review the
   release-readiness workflows / tests inside.
3. Decide: land the stash as a separate PR or abandon it.
4. Delete stale `codex/*` branches that pre-date the all-sprints
   commit (`343589f`).
5. Re-run `pnpm install && pnpm tauri build` to confirm toolchain.
6. **Pick AI provider distribution strategy before signing.**

---

## Last known reference

| Field                     | Value                                                                                                      |
| ------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `origin/main` tip         | `7a913db` chore: add pull request template                                                                 |
| Last substantive commit   | `343589f` feat: implement all sprints (2-6) — AI integration, risk scoring, comparison, templates, reports |
| Default branch            | `main`                                                                                                     |
| Build system              | Tauri 2 + Rust + React + Vite + TypeScript + Tailwind + SQLite (rusqlite)                                  |
| AI providers              | Claude + OpenAI + Ollama via `src-tauri/src/ai/provider.rs`                                                |
| Release scaffolding       | **None on `origin/main`** — but workflow files exist in local stash                                        |
| Build verification status | Untested in this pass — Cargo.toml is dirty locally                                                        |
| Blocker                   | Apple signing + stash reconciliation + AI provider decision (all operator-only)                            |
| Migration state           | `legacy-origin` present; local tracking was wrong, fixed during this pass                                  |
| Legacy-origin orphans     | 3 low-stakes `chore(codex)` commits                                                                        |
| Distinguishing feature    | **Uncommitted release-readiness WIP in stash** — recover before signing                                    |
