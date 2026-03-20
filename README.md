# Archexa

## AI-powered architecture documentation generator for any codebase

AI-powered architecture documentation generator. Analyze any codebase and get structured architecture docs, 
schema inventories, and deep technical answers — from the terminal.

Works with any OpenAI-compatible LLM. Bring your own API key.

> **Beta Release** — Fully functional, actively used on production codebases (Go, Java, Python, TypeScript). Config format and features may evolve based on feedback.

---
## Features

- 8 commands — gist, query, analyze, impact, review, chat, init, doctor.
- Two modes — Pipeline (fast, broad, 1-2 LLM calls) and Deep/Agent (thorough, reads actual files, 10-50 tool calls).
- Interactive chat — multi-turn codebase exploration with memory, topic detection, and /deep toggle per turn 
- 15+ languages — Python, Go, Java, TypeScript, Rust, C/C++, C#, Ruby, PHP, Kotlin, Scala, Swift, and more via Tree-sitter AST parsing 
- Any LLM provider — OpenAI, Anthropic, OpenRouter, Azure, Ollama, or any OpenAI-compatible endpoint 
- Custom prompts — control output format, sections, tables, diagrams per command or mid-session with /format 
- Evidence-based — citations to actual files and line numbers, validated post-generation 
- Smart token management — adaptive compaction, deduplication, budget-aware trimming for large codebases 
- Single binary — no Python install required, runs on macOS (ARM/Intel), Linux (x64/ARM), Windows

--- 
## Quick Start

```bash
# macOS / Linux — one-line install
curl -fsSL https://raw.githubusercontent.com/ereshzealous/archexa/refs/heads/main/install.sh | bash
```

The installer auto-detects your platform (macOS ARM/Intel, Linux x64/ARM) and downloads the right binary.

### macOS Gatekeeper

macOS may block the binary since it is not notarized with Apple. 
This is expected for beta releases — notarization is planned for the stable release.

**Option 1** (recommended): 

Open **System Settings → Privacy & Security** → scroll down → click **"Allow Anyway"**

**Option 2** (terminal):

```bash
sudo xattr -rd com.apple.quarantine <PATH of Binary>
```

macOS 15 (Sequoia) users: Option 1 is the most reliable.

> **Windows users:** Use forward slashes in paths: `source: "D:/projects/my-repo"` (not backslashes).

### Manual Download

Download from [Releases](https://github.com/ereshzealous/archexa/releases):

| Binary                       | Platform                    |
|------------------------------|-----------------------------|
| `archexa-macos-arm64`        | Apple Silicon (M1/M2/M3/M4) |
| `archexa-macos-x86_64`       | Intel Mac                   |
| `archexa-linux-x86_64`       | Linux x64                   |
| `archexa-linux-arm64`        | Linux ARM64                 |
| `archexa-windows-x86_64.exe` | Windows (x86_64)            |

After download: `chmod +x archexa-* && sudo mv archexa-* /usr/local/bin/archexa`

---
## Getting Started

### `init` — Create Config File

The first thing to do after install. Creates `archexa.yaml` with all available settings.

```bash
archexa init                           # Creates archexa.yaml in current directory
archexa init --out my-config.yaml      # Custom path
archexa init --base-path /path/to/repo # Pre-set the source path
```

Edit the generated file — at minimum set `model` and `endpoint`.

### `doctor` — Diagnose Setup Issues

If something isn't working, run doctor to check your configuration, API key, and LLM endpoint connectivity.

```bash
archexa doctor                         # Uses default archexa.yaml
archexa doctor --config my-config.yaml # Custom config
```

Doctor validates:
- Config file exists and parses correctly
- API key is set
- LLM endpoint is reachable
- Model responds to a test prompt

```bash
# 1. Create config file
archexa init

# 2. Edit archexa.yaml — set your model and endpoint (see "Choosing a Model" below)

# 3. Set your API key
export OPENAI_API_KEY=your-key-here

# 4. Run
archexa gist                                          # Quick codebase overview
archexa query --query "How does auth work?" --deep    # Targeted deep investigation
archexa chat                                          # Interactive exploration session
```
---
## How It Works

Archexa operates in two modes. Understanding the difference is key to getting good results.

### Pipeline Mode (default)

The pipeline analyzes your entire codebase through static analysis and generates documentation in one pass.

Codebase → Static Analysis → Evidence Compaction → LLM Generation → Document

1. **Scan** — Parses the entire codebase using Tree-sitter AST analysis and pattern matching across 15+ languages. Extracts imports, classes, interfaces, communication patterns (REST, Kafka, gRPC), dependencies, and architecturally significant code blocks.
2. **Compact** — Fits the extracted evidence within your model's token budget. Adaptively retries with progressively smaller evidence caps if the codebase is large.
3. **Plan** (analyze command only) — An LLM call selects the most architecturally relevant files and prioritizes what to document. Other commands skip this step.
4. **Generate** — An LLM call produces the final structured Markdown document from the compacted evidence.

  |            | gist, query, impact, review | analyze                 |
  |------------|-----------------------------|-------------------------|
  | LLM calls  | 1 (generator only)          | 2 (planner + generator) |
  | Speed      | 5-15 seconds                | 1-4 minutes             |
  | Token cost | ~15-30K tokens              | ~150-200K tokens        |

**Best for:** _Overviews, high-level design, broad questions, fast results at low cost._

### Agent Mode (`--deep`)
The agent investigates your codebase like a developer would — reading files, searching for patterns, tracing flows, and following leads iteratively before writing the document.

``` Codebase → Light Scan → Agent Investigation → Evidence Assembly → Synthesis → Document```

1. **Light scan** — Quick structural metadata extraction (faster than full pipeline analysis).
2. **Investigation** — The agent runs an iterative exploration loop, typically 5-15 rounds:

     **Each round, the agent can:**
     - **Read source files** — opens specific files or line ranges to examine implementation details
     - **Search the codebase** — finds files matching regex patterns across the entire repository
     - **Explore structure** — navigates directory trees to understand project organization
     - **Trace references** — follows where symbols are defined, imported, and used

    The agent makes 2-4 actions per round (10-50 total across the investigation). It decides what to explore next based on what it found in previous rounds — following imports, reading referenced files, tracing call chains.

3. **Evidence assembly** — All investigation findings are collected into a clean evidence block. Redundant file reads are deduplicated automatically.
4. **Synthesis** — An LLM call generates the final document from the assembled evidence, with citations to specific files and line numbers.

**Best for:** _Targeted questions, code-level detail, tracing specific flows, exhaustive documentation._

### Comparison

  |                      | Pipeline (default)                      | Agent (`--deep`)             |
  |----------------------|-----------------------------------------|------------------------------|
  | **Speed**            | 5-15 seconds                            | 30-120 seconds               |
  | **Token cost**       | (~$0.05)                                | (~$0.30-$0.60)               |
  | **LLM calls**        | 1-2                                     | 10-50+                       |
  | **How it sees code** | Compacted evidence from static analysis | Reads actual source files    |
  | **Accuracy**         | Good for broad questions                | Best for specific questions  |
  | **Coverage**         | Entire codebase at once                 | Deep on investigated areas   |
  | **Citations**        | File names                              | File names with line numbers |

### When to Use Which

**Pipeline (default):**
- "What does this project do?"
- "What tech stack is used?"
- "How do services communicate?"
- "Give me a high-level overview"

**Agent (`--deep`):**

- "How does JWT validation work exactly?"
- "Document every MongoDB collection with field definitions"
- "Trace the payment flow from API to database"
- "What authentication mechanisms does this platform use?"

### Config

  ```yaml
  deep:
    enabled: false        # true = agent mode for all commands by default
    max_iterations: 15    # max investigation rounds (1-50)
  ```
Or use --deep flag per command: archexa query --query "..." --deep

## Choosing a Model
The quality of generated documentation depends directly on the model you use. Archexa works with any OpenAI-compatible model — but results vary significantly.                                                                                                                                                           

### Model Recommendations                                                                                                                                                                                                                                                                                                
                                                            
  | Model                | Context Window | Quality   | Speed          | Cost (per 1M input) | Best For                                  |                                                                                                                                                                                                                                            
  |----------------------|----------------|-----------|----------------|---------------------|-------------------------------------------|
  | Claude Opus 4        | 200K           | Excellent | Medium         | ~$15.00             | Most thorough analysis, complex codebases |                                                                                                                                                                                                                      
  | Claude Sonnet 4      | 200K           | Excellent | Fast           | ~$3.00              | Detailed technical docs, best overall     |                                                                                                                                                                                                                           
  | Claude Haiku 4.5     | 200K           | Good      | Fast           | ~$0.80              | Cost-effective for large repos            |
  | GPT-4o               | 128K           | Excellent | Fast           | ~$2.50              | Best balance of quality and cost          |                                                                                                                                                                                                                                         
  | GPT-4.1              | 1M             | Excellent | Fast           | ~$2.00              | Structured output, tables, diagrams       |
  | GPT-4o-mini          | 128K           | Good      | Very fast      | ~$0.15              | Quick gists, simple queries               |                                                                                                                                                                                                                                         
  | GPT-4.1-mini         | 1M             | Good      | Very fast      | ~$0.40              | Budget option with large context          |                                                                                                                                                                                                                                     
  | GPT-4.1-nano         | 1M             | Basic     | Very fast      | ~$0.10              | Rapid prototyping only                    |                                                                                                                                                                                                                                              
  | Gemini 2.5 Pro       | 1M             | Excellent | Fast           | ~$1.25              | Largest context, cost-effective           |                                                                                                                                                                                                                                    
  | Gemini 2.5 Flash     | 1M             | Good      | Very fast      | ~$0.15              | Budget with decent quality                |                                                                                                                                                                                                                                       
  | Llama 3 70B (Ollama) | 128K           | Good      | Depends on GPU | Free                | Air-gapped, privacy-sensitive             |                                                                                                                                                                                                                           
  | Llama 3 8B (Ollama)  | 8K             | Basic     | Fast on CPU    | Free                | Quick local testing only                  |
  
### What Model Size Means for Output                                                                                                                                                                                                                                                                                     

**Large models (Claude Opus/Sonnet, GPT-4o, GPT-4.1, Gemini Pro):**
- Produce comprehensive, well-structured documents (20-60 KB)
- Follow complex prompt instructions (custom sections, tables, diagrams)
- Generate accurate mermaid diagrams
- Handle large evidence blocks without losing detail
- Trace multi-step execution flows correctly                                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                                           
**Medium models (Claude Haiku, GPT-4o-mini, GPT-4.1-mini, Gemini Flash):**
- Produce decent overviews (5-15 KB)
- May miss some sections from custom prompts
- Simpler diagrams, fewer tables 
- Good enough for quick gists and simple queries                                                                                                                                                                                                                                                                         
                                                            
**Small/local models (Llama 8B, GPT-4.1-nano):**
- Produce short, surface-level output (2-5 KB)
- Often ignore custom prompt formatting instructions
- Struggle with mermaid syntax 
- Use only for quick checks, not production documentation                                                                                                                                                                                                                                                                
                                                            
### Cost Estimates by Command

  | Command            | Budget Model (~$0.15/M) | Mid Model (~$2/M) | Premium Model (~$3-15/M) |                                                                                                                                                                                                                                     
  |--------------------|-------------------------|-------------------|--------------------------|
  | `gist`             | ~$0.005                 | ~$0.05            | ~$0.08                   |                                                                                                                                                                                                                                                                                   
  | `query` (pipeline) | ~$0.005                 | ~$0.05            | ~$0.08                   |        
  | `query --deep`     | ~$0.03                  | ~$0.50            | ~$0.80                   |                                                                                                                                                                                                                                                                            
  | `analyze`          | ~$0.05                  | ~$1.00            | ~$1.50                   |                  
  | `review --deep`    | ~$0.03                  | ~$0.50            | ~$0.80                   |                                                                                                                                                                                                                                                                           
  | `impact --deep`    | ~$0.03                  | ~$0.50            | ~$0.80                   |

### Token Budget                                                                                                                                                                                                                                                                                                         
                                                            
Match `prompt_budget` to your model's context window:                                                                                                                                                                                                                                                                    
   
  | Model            | Context Window | Recommended `prompt_budget` |                                                                                                                                                                                                                                                                 
  |------------------|----------------|-----------------------------|     
  | Claude Opus 4    | 200K           | 200000                      |
  | Claude Sonnet 4  | 200K           | 200000                      |
  | Claude Haiku 4.5 | 200K           | 200000                      |                                                                                                                                                                                                                                                                                     
  | GPT-4o           | 128K           | 128000 (default)            |                                                                                                                                                                                                                                                                                     
  | GPT-4.1          | 1M             | 200000-500000               |                                                                                                                                                                                                                                                                                         
  | GPT-4.1-mini     | 1M             | 200000                      |                                                                                                                                                                                                                                                                                           
  | GPT-4o-mini      | 128K           | 128000                      |                           
  | Gemini 2.5 Pro   | 1M             | 200000-500000               |                                                                                                                                                                                                                                                                                  
  | Gemini 2.5 Flash | 1M             | 200000                      |                                                                                                                                                                                                                                                                                       
  | Llama 3 70B      | 128K           | 100000                      |                                                                                                                                                                                                                                                                                          
  | Llama 3 8B       | 8K             | 6000                        |                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                           
Set `prompt_reserve` to at least 16000 (tokens reserved for LLM output). For long documents increase to 20000-30000.

> ** Tip:** For models with 1M context windows (GPT-4.1, Gemini Pro), you don't need to set `prompt_budget` to 1M. 
Evidence from most codebases fits within 200K. Only increase beyond 200K for very large repos (5000+ files). 

## Global Options

All commands support these flags:

| Flag | Description |
|------|-------------|
| `--config PATH` | Path to config file (default: `archexa.yaml`) |
| `--api-key KEY` | API key (overrides `OPENAI_API_KEY` env var) |
| `--no-color` | Disable colored output |
| `--quiet`, `-q` | Suppress all output except errors and final output path |
| `--version` | Show version |
| `-h`, `--help` | Show help |

Analysis commands (`gist`, `query`, `analyze`, `impact`, `review`, `chat`) also support:

| Flag | Description |
|------|-------------|
| `--deep` | Use agentic investigation mode |
| `--fresh` | Bypass evidence cache, force fresh scan |

---

## Commands

### `gist` — Quick Codebase Overview

Get a concise summary of what a codebase does, its tech stack, and how components connect.

```bash
archexa gist                    # Pipeline mode (fast)
archexa gist --deep             # Deep mode (agent reads actual files)
```

### `query` — Ask a Question

Ask a targeted question and get a focused, evidence-backed answer.

```bash
archexa query --query "How does user authentication work?"
archexa query --query "What databases are used and how?" --deep
```

You can set the question and custom formatting in config:

```yaml
query:
  question: "How does the payment flow work end to end?"
prompts:
  query: |
    Generate tables for all components involved.
    Include mermaid diagrams for flows.
    No evidence blocks in output.
```
### `analyze` — Full Architecture Documentation

Generates comprehensive architecture documentation for the entire repository. This is the only command with a planner phase — an LLM call that reads all compacted evidence and selects the most architecturally relevant files to document in detail.

```bash
archexa analyze
archexa analyze --config my-project.yaml
```

The pipeline: scan → extract evidence → compact → planner (selects files) → generator (writes document). Two LLM calls total. 

Best for generating a complete architecture reference document that a new team member could use to understand the entire system.

**Query vs Analyze:** Both can generate comprehensive documentation, but they work differently:
- `query` answers a **specific question** — it discovers files relevant to your question and generates a focused document. Works in both pipeline and deep mode.
- `analyze` generates a **full architecture reference** for the entire repo — it uses a planner to select the most important files across the whole codebase, regardless of any specific question.

For targeted documentation ("explain the auth system", "document all DB schemas"), use `query --deep`. 
For a complete repository overview, use `analyze`.

### `impact` — Change Impact Analysis

Understand what breaks **before** you change something. Impact analysis starts from a target file and traces outward — the opposite of query which starts from a question and traces inward.

```bash
# What breaks if I rename a field in the user model?
archexa impact --target "src/models/user.go" --query "Renaming the email field to primary_email"

# What depends on the auth middleware?
archexa impact --target "src/api/middleware.go" --deep

# Multiple targets
archexa impact --target "src/models/user.go,src/models/profile.go" --query "Splitting user and profile"
```
**How it works:**
1. Reads the target file(s) and extracts all symbols (classes, methods, fields, types, constants, endpoints, topics)
2. Greps the entire codebase for references to those symbols
3. Builds a reverse dependency map — "who imports/calls/references this?"
4. Traces transitive dependencies (A depends on B, B depends on target → A is affected)
5. Checks communication links (Kafka topics, REST endpoints, gRPC services) for cross-service impact
6. Generates a risk-assessed impact report

**Output includes:**
- Direct dependents (files that directly import/reference the target)
- Transitive dependents (files that depend on the direct dependents)
- Communication partners (services connected via Kafka/REST/gRPC)
- Risk assessment (LOW/MEDIUM/HIGH based on number and type of affected files)
- Recommended testing scope

Set defaults in config:

```yaml
query:
  target: "src/models/user.go"
  question: "Changing the user model schema"
```

### `review` — Code Review

Architecture-aware code review that goes beyond linting. Traces callers, follows data flow across files, checks both sides of interfaces, and identifies real issues like security vulnerabilities, resource leaks, and cross-file contract mismatches.

**Review specific files:**
```bash
archexa review --target src/api/auth.py --deep
archexa review --target src/api/auth.py,src/api/middleware.py --deep
```
Reviews the listed files plus automatically pulls in sibling files from the same directory for context.

**Review uncommitted changes:**
```bash
archexa review --changed --deep
```
Reads your `git diff` (uncommitted changes) and reviews only the changed code. Useful as a pre-commit check — "did I break anything?"

**Review a branch diff (PR-style):**
```bash
archexa review --branch origin/main..HEAD --deep
```
Reviews all changes between two git refs. Ideal for pull request reviews — shows the diff context to the LLM so it understands what changed, not just what exists.

**Review full repository:**
```bash
archexa review --deep
```
Reviews the entire codebase for architectural issues, security concerns, and tech debt. Scope is capped at 200 files (with a warning if exceeded).

**What review finds:**
- Security vulnerabilities (hardcoded secrets, missing auth, injection risks)
- Performance issues (N+1 queries, missing indexes, unbounded loops)
- Resource leaks (unclosed connections, missing defer/finally)
- Cross-file contract mismatches (API returns different shape than caller expects)
- Error handling gaps (swallowed errors, missing validation)
- Architectural concerns (circular dependencies, god classes, tight coupling)

### `chat` — Interactive Exploration (Experimental)

Conversational codebase exploration with memory across turns. Default mode is pipeline (fast). Use `/deep` for agent investigation on specific turns.

```bash
archexa chat
archexa chat --config my-project.yaml
```

**Basic usage:**

```
archexa> How does authentication work?
  [pipeline mode — streams detailed response from compacted evidence]
  -- Turn 1 (pipeline): 18,432 tokens, 8.2s

archexa> /deep show me the JWT validation code specifically
  deep mode
  [agent reads auth.go, middleware.go, traces the validation flow]
  -- Turn 2 (deep): 15 tools, 8 files, 142,300 tokens, 35.1s

archexa> summarize that in 2 sentences
  follow-up (no investigation)
  [instant response working from Turn 2's content]
  -- Turn 3 (follow-up): 3,200 tokens, 2.8s
```

**Setting output format with `/format`:**

```
archexa> /format
  Enter format. Type /done on its own line to finish:
  | ## Overview
  | ## Components (table: name, file, responsibility)
  | ## Architecture Diagram (mermaid)
  | ## Execution Flow (numbered steps)
  | ## Data Flow (mermaid)
  | ## Key Interfaces (table)
  | ## Risks and Recommendations
  |
  | Rules:
  | - Use tables for all structured data
  | - Include at least 2 mermaid diagrams
  | - No evidence blocks or raw code
  | /done

  Format set. All responses will follow this structure.

archexa> How do services communicate?
  [response follows the exact structure defined above]
```

**Saving and exporting:**

```
archexa> /save auth-analysis.md
  Saved last response to auth-analysis.md

archexa> /save all full-session.md
  Saved all 5 turns to full-session.md
```

**Viewing session stats:**

```
archexa> /usage
  Session Usage
  Turn | Mode     | Question                      | Tokens  | Tools | Time
     1 | pipeline | How does authentication work?  |  18,432 |     - |  8.2s
     2 | deep     | show me the JWT validation...  | 142,300 |    15 | 35.1s
     3 | follow-up| summarize that in 2 sentences   |   3,200 |     - |  2.8s
       | 3 turns  |                                 | 163,932 |    15 | 46.1s
  Estimated cost: $0.52

archexa> /history
  Turn 1: How does authentication work?  (0 tools, 0 files, 8.2s)
  Turn 2: show me the JWT validation...  (15 tools, 8 files, 35.1s)
  Turn 3: summarize that in 2 sentences  (0 tools, 0 files, 2.8s)
```

**Other commands:**

```
archexa> /retry                     # re-run last question with fresh investigation
  Retrying: summarize that in 2 sentences

archexa> /format show               # see current format
  Current format:
    ## Overview
    ## Components (table)
    ...

archexa> /format clear              # reset to default style
  Format cleared. Using default style.

archexa> /clear                     # reset conversation history
  Session cleared. History and context reset.

archexa> /help                      # show all commands
archexa> /exit                      # end session
```

**Session commands reference:**

| Command            | What It Does                                             |
|--------------------|----------------------------------------------------------|
| `/deep <question>` | Agent investigation for this turn only                   |
| `/format`          | Set output structure — multiline input, end with `/done` |
| `/format show`     | Display current format                                   |
| `/format clear`    | Reset to default style                                   |
| `/save <file>`     | Save last response to a file                             |
| `/save all <file>` | Save full session to a file                              |
| `/retry`           | Re-run last question with fresh investigation            |
| `/clear`           | Reset conversation history and investigated files        |
| `/history`         | Show turn history with stats                             |
| `/usage`           | Show per-turn token breakdown and session totals         |
| `/help`            | List all available commands                              |
| `/exit`            | End the session (shows session summary)                  |

**How memory works:**
- Default mode is pipeline (fast, broad) — type questions normally
- `/deep` opts into agent mode for one turn only, then reverts to pipeline
- Related questions accumulate context (up to 4 turns by default, configurable)
- Topic switches are auto-detected by an LLM classification call — history cleared, fresh start
- Follow-ups ("summarize that", "make it shorter", "in bullet points") skip investigation entirely and work on the stored response
- `/clear` manually resets all history and investigated files
- Investigated files list carries forward even after topic switches (agent won't re-read files it already examined)

---
## Provider Setup

### OpenAI

```yaml
openai:
  model: "gpt-4o"
  endpoint: "https://api.openai.com/v1/"
```
```bash
export OPENAI_API_KEY=sk-...
```

### Anthropic (via OpenRouter)

```yaml
openai:
  model: "anthropic/claude-sonnet-4-20250514"
  endpoint: "https://openrouter.ai/api/v1/"
```
```bash
export OPENAI_API_KEY=sk-or-...   # OpenRouter key
```

### Azure OpenAI

```yaml
openai:
  model: "gpt-4o"
  endpoint: "https://your-resource.openai.azure.com/openai/deployments/gpt-4o/v1/"
  tls_verify: true
```
```bash
export OPENAI_API_KEY=your-azure-key
```

### Ollama (local, free)

```bash
ollama pull llama3
ollama serve
```

```yaml
openai:
  model: "llama3"
  endpoint: "http://localhost:11434/v1/"
  tls_verify: false
```
```bash
export OPENAI_API_KEY=unused    # required but not checked by Ollama
```

### Any OpenAI-Compatible API

Archexa works with any endpoint that implements the OpenAI chat completions API — LM Studio, vLLM, text-generation-inference, FastChat, corporate proxies.

```yaml
openai:
  model: "your-model-name"
  endpoint: "https://your-endpoint/v1/"
  tls_verify: false              # if using self-signed certificates
```

---
## Custom Prompts

Control the output format and focus of generated documentation:

```yaml
prompts:
  query: |
    Generate a comprehensive document with these sections:
    - Executive Summary
    - Architecture Diagram (mermaid)
    - Component Details (table format)
    - Data Flow
    - Security Analysis
    - Recommendations

    Rules:
    - Use tables for all structured data
    - Include mermaid diagrams
    - No evidence blocks or raw code in output
```

The `user` prompt applies to all commands. Command-specific prompts (`query`, `gist`, `impact`, `review`) take priority over `user`.

In chat mode, use `/format` to change output structure mid-session without restarting.

---
## Full Configuration Reference

```yaml
archexa:
  source: "/path/to/codebase"

  openai:
    model: "gpt-4o"
    endpoint: "https://api.openai.com/v1/"
    tls_verify: true

  output: "generated"
  log_level: "WARNING"                   # DEBUG, INFO, WARNING, ERROR

  limits:
    max_files: 100                       # max files for analyze planner
    prompt_budget: 128000                # max tokens for prompt context
    prompt_reserve: 16000                # tokens reserved for LLM output
    retries: 5                           # retry attempts on transient errors

  evidence:
    file_size_limit: 300000              # skip files larger than this (bytes)
    blocks_per_file: 12                  # max code blocks per file
    block_height: 120                    # max lines per code block
    lookahead: 90                        # lines after a pattern match
    lookbehind: 10                       # lines before a pattern match
    max_slices: 20                       # max focused context slices

  deep:
    enabled: false                       # true = deep mode for all commands
    max_iterations: 15                   # max agent iterations (1-50)

  chat:
    history_turns: 4                     # related turns in context (1-20)
    max_response_chars: 10000            # max chars per response in history
    relevance_check: true                # auto-detect topic switches

  prompts:
    user: ""                             # all commands
    gist: ""                             # gist only
    query: ""                            # query only
    impact: ""                           # impact only
    review: ""                           # review only

  query:
    question: ""                         # default question
    target: ""                           # default target for impact

  scan_focus: []                         # e.g. ["src/api/", "src/auth/"]
  show_evidence: false                   # show evidence summary in console
  embed_evidence: true                   # include evidence in generated doc
  cache: true                            # cache per-file extraction results
```

---

## Supported Languages

Python, Go, Java, TypeScript, JavaScript, Rust, C, C++, C#, Ruby, PHP, Kotlin, Scala, Swift, Terraform, Dockerfile, Kubernetes YAML, Protocol Buffers, GraphQL.

---

## Troubleshooting

**"API key missing"** — Set `OPENAI_API_KEY` or use `--api-key` flag.

**"Config file not found"** — Run `archexa init` or use `--config path/to/config.yaml`.

**"prompt is too long"** — Codebase is large. Reduce `prompt_budget`, add `scan_focus`, or reduce `max_iterations`.

**Slow first run** — Evidence extraction caches after first run. Set `cache: true`.

**Short/generic output** — Use a larger model. Increase `prompt_reserve`. Add detailed `prompts.query`.

**macOS "cannot be opened"** — See Gatekeeper section above.

**Garbled output in CI/SSH** — Use `--no-color --quiet` for non-interactive environments. Some terminals without UTF-8 support may render Unicode characters incorrectly.

Run `archexa doctor` to diagnose configuration and connectivity issues.

---

## Environment Variables

| Variable         | Required | Description                   |
|------------------|----------|-------------------------------|
| `OPENAI_API_KEY` | Yes      | API key for your LLM provider |

Also available via `--api-key` flag on any command.

---

## Requirements

- An OpenAI-compatible API key
- macOS (ARM or Intel), Linux (x64 or ARM), or Windows

No Python installation required — distributed as a standalone binary.

---
## Examples

See real Archexa output running against the [FastAPI](https://github.com/fastapi/fastapi) framework (2,661 files, Python, MIT licensed).

The [examples/fastapi/](examples/showcase/) folder contains configs, console output, and generated documents for every command:

| # | Command         | Mode     | Model            | Time    | Tokens | Output                                                                                   |
|---|-----------------|----------|------------------|---------|--------|------------------------------------------------------------------------------------------|
| 1 | `gist`          | Pipeline | gemini-2.5-flash | 1m 41s  | 147K   | [7.5 KB overview](examples/fastapi/ARCHITECTURE_DOC_gist_20260319_132212.md)             |
| 2 | `gist --deep`   | Agent    | gemini-2.5-flash | 58s     | 105K   | [10.0 KB with file refs](examples/fastapi/ARCHITECTURE_DOC_gist_20260319_132529_deep.md) |
| 3 | `analyze`       | Pipeline | claude-sonnet-4  | 1m 55s  | 201K   | [10.5 KB full architecture](examples/fastapi/ARCHITECTURE_DOC_20260319_133342.md)        |
| 4 | `query --deep`  | Agent    | claude-sonnet-4  | 2m 31s  | 300K   | [7.5 KB DI deep dive](examples/fastapi/ARCHITECTURE_DOC_query_20260319_134743.md)        |
| 5 | `review --deep` | Agent    | gemini-2.5-flash | 1m 46s  | 275K   | [6.8 KB security review](examples/fastapi/ARCHITECTURE_DOC_review_20260319_135353.md)    |
| 6 | `doctor`        | —        | —                | instant | —      | Diagnostics output                                                                       |
| 7 | `impact --deep` | Agent    | gpt-4.1          | 2m 50s  | 159K   | [12.4 KB impact analysis](examples/fastapi/ARCHITECTURE_DOC_impact_20260319_143105.md)   |

**Try it yourself:**

```bash
git clone https://github.com/fastapi/fastapi.git
export OPENAI_API_KEY=your-key-here
archexa gist --config examples/fastapi/config-gist.yaml
```

See [examples/showcase/README.md](examples/showcase/README.md) for full setup, all configs, and detailed console output for each run.

---

## Feedback

This is a beta release. We'd love your feedback:

- [Report issues](https://github.com/ereshzealous/archexa/issues)
- Star the repo if you find it useful

---

## License

Apache 2.0 — see [LICENSE](LICENSE).

