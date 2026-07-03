<!-- portfolio-context:start -->
# Portfolio Context

## What This Project Is

LegalDocsReview is a native desktop app for reviewing contracts and legal documents locally. It uses Tauri, React, and Rust to ingest PDFs, extract text and clauses, score risk, compare documents, and generate reports, with optional AI assistance while keeping documents and analysis in a local SQLite database.

## Current State

All core sprints (1–6) are complete — AI integration (OpenAI, Claude, local Ollama), risk scoring, document comparison, template management, report generation, and SQLite storage. The feature surface is complete; the app is pending code-signing and distribution before a public release.

## Stack

| Layer | Technology |
|-------|------------|
| Desktop shell | Tauri 2 |
| Frontend | React, TypeScript, Vite, Tailwind CSS |
| Backend | Rust — PDF text extraction, clause parsing, risk logic |
| AI providers | OpenAI Chat Completions API, Anthropic Claude Messages API, Ollama (local) |
| Storage | SQLite via rusqlite (local app data dir) |
| Testing | Vitest |

## How To Run

```bash
# Run in browser (frontend only)
pnpm dev

# Run full desktop app (Tauri + Rust backend)
pnpm tauri dev
```

AI-assisted features require an OpenAI or Anthropic API key, or a locally running Ollama instance, configured in **Settings**.

## Known Risks

- This repo only has minimum-viable recovery context today; deeper handoff details may still live in the README and supporting docs.

## Next Recommended Move

Use this context plus the README and supporting docs to resume the next active task, then promote the repo beyond minimum-viable by capturing a dedicated handoff, roadmap, or discovery artifact.

<!-- portfolio-context:end -->

<!-- comm-contract:start -->

## Communication Contract

- Inherit global Codex communication and reporting rules from `/Users/d/.codex/AGENTS.override.md` and `/Users/d/.codex/policies/communication/BigPictureReportingV1.md`.
- Repo-specific instructions below add project constraints only; do not restate global voice or status-reporting rules here.
<!-- comm-contract:end -->

## Inherited Operating Rules

- Inherit global git, review/fix, testing, docs, skill-use, and reporting gates from `/Users/d/.codex/AGENTS.md` and active session instructions.
- Use `.codex/verify.commands` and `.codex/scripts/run_verify_commands.sh` as this repo-local verification authority when present.
- Add repo-specific constraints here only when this project has instructions that differ from global Codex defaults.
