# Archexa

**AI-powered architecture documentation generator for any codebase.**

Archexa analyzes your repository using static analysis (Tree-sitter AST parsing) and LLM-driven investigation to produce comprehensive, evidence-based architecture documents — automatically.

---

## Features

- **Multi-language support** — Python, Java, Go, Rust, TypeScript, JavaScript, C/C++, C#, Ruby, PHP, Kotlin, Scala, Swift, and more
- **Evidence-based** — every architectural claim is backed by code references (E#) for full traceability
- **Deep investigation mode** — an agentic loop that reads files, traces imports, and greps patterns autonomously before generating docs
- **Multiple commands** — from quick overviews to full architecture documents, targeted queries, and impact analysis
- **Any LLM provider** — works with OpenAI, Azure OpenAI, OpenRouter, or any OpenAI-compatible API
- **Mermaid & ASCII diagrams** — system context, component, dependency, sequence, and data flow diagrams
- **Smart token management** — adaptive compaction, progressive pruning, and evidence deduplication to fit any model's context window
- **Caching** — evidence extraction results are cached for fast repeated runs

---

## Quick Start

### 1. Install

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/ereshzealous/archexa/main/install.sh | bash
```

Or download the binary manually from [Releases](https://github.com/ereshzealous/archexa/releases).

**Supported platforms:**
| Platform | Binary |
|----------|--------|
| macOS (Apple Silicon) | `archexa-macos-arm64` |
| macOS (Intel) | `archexa-macos-x86_64` |
| Linux (x86_64) | `archexa-linux-x86_64` |
| Linux (ARM64) | `archexa-linux-arm64` |
| Windows (x86_64) | `archexa-windows-x86_64.exe` |

**Manual install (macOS/Linux):**

```bash
# 1. Download the binary for your platform from Releases

# 2. Make it executable
chmod +x archexa-macos-arm64

# 3. macOS only: remove quarantine to avoid "unidentified developer" block
xattr -d com.apple.quarantine archexa-macos-arm64

# 4. Move to your PATH (rename to 'archexa')
sudo mv archexa-macos-arm64 /usr/local/bin/archexa

# 5. Verify
archexa --version
```

> **Note:** On macOS, if you skip the `xattr` step, you may see a security warning. You can also allow it via System Preferences > Security & Privacy after the first blocked run.

### 2. Configure

```bash
cd your-project
archexa init
```

This creates an `archexa.yaml` config file. Edit it to set your LLM provider:

```yaml
llm:
  model: gpt-4o
  base_url: https://api.openai.com/v1
  ssl_verify: true
```

Set your API key:

```bash
export OPENAI_API_KEY="sk-..."
```

### 3. Generate

```bash
# Quick architectural overview (30 seconds)
archexa gist --config archexa.yaml

# Full architecture document with diagrams
archexa analyze --config archexa.yaml

# Deep investigation mode (agentic, most thorough)
archexa analyze --config archexa.yaml --deep
```

---

## Commands

| Command | Purpose | Typical Use |
|---------|---------|-------------|
| `archexa gist` | Quick architectural overview | First look at a new codebase |
| `archexa analyze` | Full architecture document (HLD + LLD) | Comprehensive documentation |
| `archexa query` | Answer specific architecture questions | "How does auth work?" |
| `archexa impact` | Analyze impact of changing a file | Pre-refactor risk assessment |
| `archexa review` | Architecture review of specific files | Code review support |
| `archexa doctor` | Check environment and config | Troubleshooting setup issues |
| `archexa init` | Generate starter config | First-time setup |

### Deep Mode (`--deep`)

All analysis commands support `--deep` for agentic investigation. In this mode, Archexa:

1. **Investigates** — autonomously reads files, traces imports, greps for patterns, and explores the codebase
2. **Synthesizes** — generates the architecture document using both static evidence and investigation findings

Deep mode produces significantly more thorough and accurate documentation, especially for large or complex codebases.

---

## Configuration

See [docs/configuration.md](docs/configuration.md) for the full config reference.

Minimal example:

```yaml
project:
  base_path: .

llm:
  model: gpt-4o
  base_url: https://api.openai.com/v1

limits:
  max_files: 100
  max_prompt_tokens: 128000

output:
  out: generated
```

### LLM Providers

Archexa works with any OpenAI-compatible API:

| Provider | `base_url` | `model` |
|----------|-----------|---------|
| OpenAI | `https://api.openai.com/v1` | `gpt-4o`, `gpt-4o-mini` |
| Azure OpenAI | `https://YOUR.openai.azure.com/openai/deployments/YOUR-DEPLOYMENT/` | deployment name |
| OpenRouter | `https://openrouter.ai/api/v1` | `openai/gpt-4o`, `anthropic/claude-sonnet-4-20250514` |
| Local (Ollama) | `http://localhost:11434/v1` | `llama3`, `codellama` |

---

## Examples

The [`examples/`](examples/) directory contains:

- **[configs/](examples/configs/)** — Sample configuration files for different project types and LLM providers
- **[showcase/](examples/showcase/)** — Real architecture documents generated by Archexa for popular open-source projects

---

## Documentation

- [Getting Started](docs/getting-started.md) — Installation, setup, and first run
- [Commands](docs/commands.md) — Detailed command reference with examples
- [Configuration](docs/configuration.md) — Full `archexa.yaml` reference
- [Deep Mode](docs/deep-mode.md) — How the agentic investigation works

---

## How It Works

```
Your Codebase
     │
     ▼
┌─────────────────┐
│  Static Analysis │  Tree-sitter AST parsing
│  (Evidence       │  Interface detection
│   Extraction)    │  Dependency mapping
└────────┬────────┘  Class hierarchy + call graphs
         │
         ▼
┌─────────────────┐
│  Investigation   │  (Deep mode only)
│  Agent Loop      │  Reads files, traces imports,
│                  │  greps patterns autonomously
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Synthesis       │  LLM generates architecture
│  (Streaming)     │  document from all evidence
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Post-processing │  Citation validation
│  & Validation    │  Mermaid diagram fixes
│                  │  Prose claim checking
└────────┬────────┘
         │
         ▼
   Architecture
   Document (MD)
```

---

## License

Archexa is distributed as a pre-built binary. See [LICENSE](LICENSE) for terms.
