# LegalDocsReview

[![Rust](https://img.shields.io/badge/Rust-dea584?style=flat-square&logo=rust)](#) [![TypeScript](https://img.shields.io/badge/TypeScript-3178c6?style=flat-square&logo=typescript)](#) [![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](#)

> Review contracts and legal documents on your own machine — AI-assisted clause extraction and risk scoring without uploading sensitive docs to a cloud service.

LegalDocsReview is a native desktop app built on Tauri + React + Rust. Upload PDFs, extract text and key clauses locally, score risk, compare two documents side by side, and generate review reports — all with optional AI assistance via OpenAI or Anthropic Claude. Documents and analysis stay on your machine in a local SQLite database.

## Features

- **PDF ingestion** — upload and store PDFs locally; text extracted in Rust
- **Clause extraction** — key clauses and fields identified automatically
- **Risk scoring** — risk distribution per document with visual breakdowns
- **Document comparison** — diff two contracts to surface changed or missing clauses
- **Analysis templates** — reusable review templates for different document types
- **Review reports** — exportable reports summarizing findings
- **Dual AI support** — OpenAI Chat Completions or Anthropic Claude Messages API (API key stored locally)

## Quick Start

### Prerequisites

- Node.js 18+
- `pnpm`
- Rust stable toolchain (`rustup`)
- Tauri system dependencies: [tauri.app/start/prerequisites](https://tauri.app/start/prerequisites/)

### Installation

```bash
git clone https://github.com/saagpatel/LegalDocsReview
cd LegalDocsReview
pnpm install
```

### Usage

```bash
# Run in browser (frontend only)
pnpm dev

# Run full desktop app (Tauri + Rust backend)
pnpm tauri dev
```

AI-assisted features require an OpenAI or Anthropic API key configured in **Settings**.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Desktop shell | Tauri 2 |
| Frontend | React, TypeScript, Vite, Tailwind CSS |
| Backend | Rust — PDF text extraction, clause parsing, risk logic |
| AI providers | OpenAI Chat Completions API, Anthropic Claude Messages API |
| Storage | SQLite via rusqlite (local app data dir) |
| Testing | Vitest |

## Architecture

All document storage and analysis logic lives in the Rust backend. PDFs are stored in the app data directory; extracted text and analysis results are persisted in a local SQLite database. AI calls are made directly to the configured provider from the Rust layer — the frontend never handles raw API responses for sensitive content. Templates are managed as reusable Rust data structures.

## Current State

**Release Frozen.** All sprints (1–6) are shipped on `origin/main` — AI integration
(Claude / OpenAI / local Ollama via `src-tauri/src/ai/provider.rs`), risk scoring
(`risk_rules.rs`), file- and section-level document comparison, template management,
report generation, and SQLite document/extraction storage. The product surface is complete;
the remaining gate is release (code signing), not feature work. Full disposition:
[docs/PORTFOLIO-DISPOSITION.md](docs/PORTFOLIO-DISPOSITION.md).

## Known Risks

- **Uncommitted release-readiness WIP in a local stash** (`r8-legaldocsreview-stash`) —
  release/CI workflow files, a tests directory, smoke scripts, and `src-tauri` command mods
  that are *not* on `origin/main`. Review before it is lost.
- **Two remotes** — `origin` (`saagpatel/LegalDocsReview`) is canonical; `legacy-origin`
  (`saagar210/LegalDocsReview`) carries 3 low-stakes orphan `chore(codex)` commits. Local
  `main` was mistakenly tracking `legacy-origin`; corrected to `origin/main`.
- **Build verification is stale** — `Cargo.toml` was dirty locally during the last pass; the
  Tauri build has not been re-confirmed on the current toolchain.
- **AI provider distribution undecided** — bundle Ollama models (large `.app`), require
  operator-supplied Claude/OpenAI keys, or both. A product decision that blocks the v1 release.

## Next Recommended Move

Release is gated on operator-only steps: (1) review and reconcile the stashed
release-readiness WIP (land it as its own PR or document why it is abandoned), (2) wire Apple
Developer ID + notarization, (3) pick the AI provider distribution strategy, then (4) cut a
`v1.0.0` tag and verify the signed/notarized DMG opens without Gatekeeper warnings. Estimated
~4 hours once signing credentials are in hand.

## License

MIT
