# LegalDocsReview

[![Rust](https://img.shields.io/badge/Rust-dea584?style=flat-square&logo=rust)](https://www.rust-lang.org) [![TypeScript](https://img.shields.io/badge/TypeScript-3178c6?style=flat-square&logo=typescript)](https://www.typescriptlang.org) [![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](./LICENSE)

> Review contracts and legal documents on your own machine — AI-assisted clause extraction and risk scoring via local Ollama or cloud providers that receive document text and extracted clauses.

LegalDocsReview is a native desktop app built on Tauri + React + Rust. Upload PDFs and extract text locally; clause extraction, risk scoring, document comparison, and report summaries use OpenAI, Anthropic Claude, or Ollama. PDFs are stored in the app data directory; extracted text and analysis results are stored in a local SQLite database. Cloud providers receive document text and extracted clauses for analysis.

## Features

- **PDF ingestion** — upload and store PDFs locally; text extracted in Rust
- **Clause extraction** — key clauses and fields identified automatically
- **Risk scoring** — risk distribution per document with visual breakdowns
- **Document comparison** — diff two contracts to surface changed or missing clauses
- **Analysis templates** — store, list, and delete contract-text templates for different document types
- **Review reports** — exportable reports summarizing findings
- **Tri-provider AI support** — OpenAI Chat Completions, Anthropic Claude Messages API, or local Ollama (API key stored locally for cloud providers)

## Quick Start

### Prerequisites

- Node.js 22.12+ (22.x), 24.x, or 26+ (the locked Vitest 5 requirement)
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

AI-assisted features require an OpenAI or Anthropic API key, or a locally running Ollama instance, configured in **Settings**.

## Tech Stack

| Layer         | Technology                                                                 |
| ------------- | -------------------------------------------------------------------------- |
| Desktop shell | Tauri 2                                                                    |
| Frontend      | React, TypeScript, Vite, Tailwind CSS                                      |
| Backend       | Rust — PDF text extraction, clause parsing, risk logic                     |
| AI providers  | OpenAI Chat Completions API, Anthropic Claude Messages API, Ollama (local) |
| Storage       | SQLite via rusqlite (local app data dir)                                   |
| Testing       | Vitest                                                                     |

## Architecture

Document storage and analysis orchestration live in the Rust backend. PDFs are stored in the app data directory; extracted text and analysis results are persisted in a local SQLite database. AI calls are made directly to the configured provider from the Rust layer — the frontend receives parsed analysis results rather than raw provider responses. Templates are stored in SQLite; document comparison currently accepts two documents, not templates.

## Current State

All core sprints (1–6) are complete — AI integration (OpenAI, Claude, local Ollama), risk scoring, document comparison, template management, report generation, and SQLite storage. Template comparison and the report Open File action are not implemented; the app is pending code-signing and distribution before a public release.

## Roadmap

- macOS code-signing and notarization for Gatekeeper-free distribution
- Some release-readiness scaffolding is not yet merged
- AI provider distribution strategy (bundled Ollama models vs. user-supplied API keys)
- CI/CD pipeline for automated builds

## Developer verification

See [developer verification](docs/VERIFICATION.md) for focused Vitest checks, TypeScript/build and performance gates, and native/provider boundaries.

## License

MIT
