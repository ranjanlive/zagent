# Changelog

All notable changes to `zagent` are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-10-11

First public development release.

### Added
- **Multi-Provider Streaming Adapters:** Native support for Google Gemini, OpenAI-compatible (Ollama, vLLM, OpenRouter, Azure OpenAI), Anthropic Messages, and custom gateways with token usage reporting and URL normalisation.
- **Append-Only Session Logging:** Event-sourced `events.jsonl` architecture with content-addressed blob storage (`blobs/`), crash-safe load/resume, and OS-held single-writer locking.
- **Deterministic Context Management:** Byte-identical request rendering for maximum provider prefix-cache hits; per-turn attachment pruning, exact HTTP body-size guards (preventing 413s), and token-threshold compaction.
- **Network Resilience & Recovery:** Exponential backoff retry, automatic pause on network failure with delayed retry, and repair of interrupted/orphaned tool calls on session resume.
- **Native Tools:** Built-in tools for file viewing/editing, shell command execution with background task supervision, persistent/workspace memory, agent skills, and fresh-context sub-agents.
- **Third-Party Tool Protocol:** Support for external tools via JSON manifests (`tools/<name>/<name>.json`) with standard input/output streaming, execution timeouts, and progress notification channels.
- **Unified Interfaces:** Headless execution (`zagent -p`), terminal UI (`zagent --ui cli`), and browser dashboard (`zagent --ui web`) all backed by a single authenticated local control API (127.0.0.1).
- **Interactive Slash Commands:** `/help`, `/stop`, `/note`, `/compact`, `/status`, `/tasks`, `/tools`, `/workspace`, `/resume`, `/exit`, `/quit`, and custom user markdown commands.
- **Inspection & Diagnostics:** CLI commands `zagent init`, `zagent doctor`, `zagent sessions`, `zagent show`, and `zagent tools list|run`.
