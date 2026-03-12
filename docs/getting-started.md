# Getting Started

## Installation

### Binary Install (Recommended)

Download the pre-built binary for your platform:

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/ereshzealous/archexa/main/install.sh | bash
```

Or download directly from [Releases](https://github.com/ereshzealous/archexa/releases).

**Custom install location:**

```bash
INSTALL_DIR=~/.local/bin curl -fsSL https://raw.githubusercontent.com/ereshzealous/archexa/main/install.sh | bash
```

### Manual Install (macOS / Linux)

If you download the binary manually from Releases:

```bash
# 1. Make it executable
chmod +x archexa-macos-arm64

# 2. macOS only: remove quarantine to avoid "unidentified developer" block
xattr -d com.apple.quarantine archexa-macos-arm64

# 3. Move to your PATH (rename to 'archexa')
sudo mv archexa-macos-arm64 /usr/local/bin/archexa
```

> **macOS security note:** If you skip the `xattr` step, macOS may block the binary with an "unidentified developer" warning. You can also allow it via **System Preferences > Security & Privacy** after the first blocked run.

### Manual Install (Windows)

1. Download `archexa-windows-x86_64.exe` from [Releases](https://github.com/ereshzealous/archexa/releases)
2. Rename to `archexa.exe`
3. Place in a directory that is in your `PATH` (e.g., `C:\Users\<you>\bin\`)
4. Or run directly: `.\archexa.exe --version`

### Verify Installation

```bash
archexa --version
archexa doctor
```

The `doctor` command checks your environment: API connectivity, config validity, and Tree-sitter availability.

---

## First Run

### 1. Create a Config File

Navigate to the project you want to document:

```bash
cd /path/to/your/project
archexa init
```

This creates `archexa.yaml` with sensible defaults. Open it and set your LLM provider:

```yaml
llm:
  model: gpt-4o
  base_url: https://api.openai.com/v1
```

### 2. Set Your API Key

```bash
export OPENAI_API_KEY="sk-..."
```

For Azure OpenAI:
```bash
export AZURE_OPENAI_API_KEY="..."
```

For OpenRouter:
```bash
export OPENAI_API_KEY="sk-or-..."
```

### 3. Generate Your First Document

Start with a quick overview:

```bash
archexa gist --config archexa.yaml
```

This produces a concise architectural summary in ~30 seconds. Output goes to the `generated/` directory by default.

### 4. Go Deeper

For a full architecture document:

```bash
archexa analyze --config archexa.yaml
```

For the most thorough analysis (agentic investigation):

```bash
archexa analyze --config archexa.yaml --deep
```

---

## Understanding the Output

Archexa generates Markdown documents with:

- **Evidence references** (E#) — each claim links back to specific code evidence
- **Diagrams** — Mermaid syntax for system context, component, sequence, and data flow diagrams
- **HLD** — High-Level Design: service summary, components, interfaces, dependencies
- **LLD** — Low-Level Design: call chains, sequence diagrams, DB interactions
- **Gaps & Uncertainties** — areas the analysis couldn't fully verify

---

## Project Size Guidelines

| Project Size | Files | Recommended Config |
|-------------|-------|-------------------|
| Small | < 50 | Default settings |
| Medium | 50-200 | `max_files: 200` |
| Large | 200-1000 | `max_files: 300`, consider `--deep` |
| Very Large | 1000+ | Use `service.focus` to scope, `--deep` recommended |

For large monorepos, use `service.focus` to analyze one service at a time:

```yaml
service:
  focus:
    - order-service
    - payment-service
```

---

## Troubleshooting

### "Config file not found"

Run `archexa init` in your project directory, or pass `--config /path/to/archexa.yaml`.

### "API connection failed"

Run `archexa doctor` to diagnose. Common issues:
- Missing API key environment variable
- Incorrect `base_url` in config
- Network/proxy issues (`ssl_verify: false` for self-signed certs)

### "Over token budget"

Reduce scope:
- Lower `limits.max_files`
- Use `service.focus` to target specific directories
- Increase `limits.max_prompt_tokens` if your model supports it

### Slow first run

The first run parses every file with Tree-sitter. Subsequent runs use the cache (`.archexa_cache/`). Use `--fresh` to bypass cache when needed.
