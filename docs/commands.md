# Command Reference

## Global Options

All commands support these flags:

| Flag | Description |
|------|-------------|
| `--config PATH` | Path to `archexa.yaml` config file (default: `archexa.yaml`) |
| `--no-color` | Disable colored console output |
| `--quiet`, `-q` | Suppress all output except errors and the final output path |
| `--version` | Show version |
| `-h`, `--help` | Show help |

---

## `archexa init`

Generate a starter configuration file.

```bash
archexa init
archexa init --out my-config.yaml --base-path ./src
```

| Option | Default | Description |
|--------|---------|-------------|
| `--out PATH` | `archexa.yaml` | Where to write the config file |
| `--base-path PATH` | `.` | Project root path |

---

## `archexa gist`

Generate a quick architectural overview. Fast, concise, good for first impressions.

```bash
archexa gist --config archexa.yaml
archexa gist --config archexa.yaml --deep
archexa gist --config archexa.yaml --out overview.md
```

| Option | Default | Description |
|--------|---------|-------------|
| `--config PATH` | `archexa.yaml` | Config file |
| `--out PATH` | From config | Output file path |
| `--deep` | `false` | Use agentic investigation |
| `--fresh` | `false` | Bypass evidence cache |

**Output:** A concise Markdown document covering architecture style, key components, tech stack, entry points, and data flow.

---

## `archexa analyze`

Generate a full architecture document with HLD (High-Level Design) and LLD (Low-Level Design).

```bash
archexa analyze --config archexa.yaml
archexa analyze --config archexa.yaml --deep
archexa analyze --config archexa.yaml --prompt "Focus on the payment processing pipeline"
```

| Option | Default | Description |
|--------|---------|-------------|
| `--config PATH` | `archexa.yaml` | Config file |
| `--out PATH` | From config | Output file path |
| `--deep` | `false` | Use agentic investigation |
| `--fresh` | `false` | Bypass evidence cache |
| `--prompt TEXT` | From config | Custom instructions for the LLM |

**Output:** A comprehensive Markdown document including:
- System overview and tech stack
- High-Level Design (components, interfaces, dependency graph, data flow)
- Low-Level Design (call chains, sequence diagrams, DB interactions)
- Communication topology (if applicable)
- Gaps & uncertainties

---

## `archexa query`

Ask a specific architecture question about the codebase.

```bash
archexa query --config archexa.yaml --query "How does authentication work?"
archexa query --config archexa.yaml --query "What happens when a user places an order?" --deep
archexa query --config archexa.yaml --query "Explain the caching strategy"
```

| Option | Default | Description |
|--------|---------|-------------|
| `--config PATH` | `archexa.yaml` | Config file |
| `--query TEXT` | From config | The question to answer |
| `--out PATH` | From config | Output file path |
| `--deep` | `false` | Use agentic investigation |
| `--fresh` | `false` | Bypass evidence cache |

**Output:** A focused Markdown document answering the question with code evidence.

---

## `archexa impact`

Analyze the impact of changing a specific file or module.

```bash
archexa impact --config archexa.yaml --target src/auth/login.py
archexa impact --config archexa.yaml --target src/api/handlers.go --deep
```

| Option | Default | Description |
|--------|---------|-------------|
| `--config PATH` | `archexa.yaml` | Config file |
| `--target PATH` | From config | File(s) to analyze impact for (comma-separated) |
| `--out PATH` | From config | Output file path |
| `--deep` | `false` | Use agentic investigation |
| `--fresh` | `false` | Bypass evidence cache |

**Output:** A Markdown document covering:
- What the target file does
- Direct and transitive dependents
- Affected interfaces and data flows
- Risk assessment and testing recommendations

---

## `archexa review`

Architecture-focused review of specific files or recent changes.

```bash
# Review specific files
archexa review --config archexa.yaml --target src/api/auth.py --deep

# Review recent git changes
archexa review --config archexa.yaml --changed --deep
```

| Option | Default | Description |
|--------|---------|-------------|
| `--config PATH` | `archexa.yaml` | Config file |
| `--target PATH` | None | File(s) to review (comma-separated) |
| `--changed` | `false` | Review uncommitted git changes instead |
| `--out PATH` | From config | Output file path |
| `--deep` | `false` | Use agentic investigation |
| `--fresh` | `false` | Bypass evidence cache |

**Output:** An architecture review covering design patterns, coupling, cohesion, and improvement suggestions.

---

## `archexa doctor`

Check environment setup and configuration.

```bash
archexa doctor
archexa doctor --config archexa.yaml
```

Checks:
- Python version
- Config file validity
- LLM API connectivity
- Tree-sitter parser availability
- Cache directory status

---

## The `--deep` Flag

The `--deep` flag enables agentic investigation mode on any analysis command. In this mode:

1. The agent receives a repository overview (file tree, detected interfaces, class hierarchy)
2. It autonomously decides which files to read, patterns to grep, and imports to trace
3. After investigation (up to `agent.max_iterations` rounds), it synthesizes the final document

**When to use `--deep`:**
- Large codebases (100+ files)
- Complex architectures (microservices, event-driven)
- When standard mode misses important details
- When you need maximum accuracy

**Trade-offs:**
- Slower (investigation takes multiple LLM calls)
- Uses more API tokens
- Significantly more thorough and accurate
