# LegalDocsReview

[![Rust](https://img.shields.io/badge/Rust-dea584?style=flat-square&logo=rust)](https://www.rust-lang.org) [![TypeScript](https://img.shields.io/badge/TypeScript-3178c6?style=flat-square&logo=typescript)](https://www.typescriptlang.org) [![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](./LICENSE)

> Review contracts and legal documents on your own machine — AI-assisted clause extraction and risk scoring without uploading sensitive docs to a cloud service.

LegalDocsReview is a native desktop app built on Tauri + React + Rust. Upload PDFs, extract text and key clauses locally, score risk, compare two documents side by side, and generate review reports — all with optional AI assistance via OpenAI or Anthropic Claude. Documents and analysis stay on your machine in a local SQLite database.

## Features

- **PDF ingestion** — upload and store PDFs locally; text extracted in Rust
- **Clause extraction** — key clauses and fields identified automatically
- **Risk scoring** — risk distribution per document with visual breakdowns
- **Document comparison** — diff two contracts to surface changed or missing clauses
- **Analysis templates** — reusable review templates for different document types
- **Review reports** — exportable reports summarizing findings
- **Tri-provider AI support** — OpenAI Chat Completions, Anthropic Claude Messages API, or local Ollama (API key stored locally for cloud providers)

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

AI-assisted features require an OpenAI or Anthropic API key, or a locally running Ollama instance, configured in **Settings**.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Desktop shell | Tauri 2 |
| Frontend | React, TypeScript, Vite, Tailwind CSS |
| Backend | Rust — PDF text extraction, clause parsing, risk logic |
| AI providers | OpenAI Chat Completions API, Anthropic Claude Messages API, Ollama (local) |
| Storage | SQLite via rusqlite (local app data dir) |
| Testing | Vitest |

## Architecture

All document storage and analysis logic lives in the Rust backend. PDFs are stored in the app data directory; extracted text and analysis results are persisted in a local SQLite database. AI calls are made directly to the configured provider from the Rust layer — the frontend never handles raw API responses for sensitive content. Templates are managed as reusable Rust data structures.

## Current State

All core sprints (1–6) are complete — AI integration (OpenAI, Claude, local Ollama), risk scoring, document comparison, template management, report generation, and SQLite storage. The feature surface is complete; the app is pending code-signing and distribution before a public release.

## Roadmap

- macOS code-signing and notarization for Gatekeeper-free distribution
- Some release-readiness scaffolding is not yet merged
- AI provider distribution strategy (bundled Ollama models vs. user-supplied API keys)
- CI/CD pipeline for automated builds

## License

MIT
