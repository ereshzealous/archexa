# Archexa Examples — FastAPI
Real-world examples of Archexa running against the [FastAPI](https://github.com/fastapi/fastapi) framework (MIT licensed, 2,661 files, Python).

Each example shows the config used, console output, and the generated document — so you can see exactly what Archexa produces before running it yourself.

---
## Setup

```bash
# Clone FastAPI
git clone https://github.com/fastapi/fastapi.git
# Set your API key (OpenRouter, OpenAI, or any compatible provider)
export OPENAI_API_KEY=your-key-here
```
---
## Example 1 — Gist (Pipeline Mode)

**What:** Quick codebase overview using compacted evidence in a single LLM call.

**Config:** [config-gist.yaml](config-gist.yaml) | **Model:** `google/gemini-2.5-flash` | **Mode:** Pipeline

```bash
archexa gist --config examples/fastapi/config-gist.yaml
```

**Console Output:**
```
  Codebase Gist
  Project: ./fastapi

  [1/4] Scanning repository  ─  2,661 files  0.1s
  [2/4] Extracting structural metadata  ─  2661 files | 3842 blocks | 35492 dep edges  4.6s
  [3/4] Fitting token budget  ─  111,341 / 112,000 tokens  0.4s
  [4/4] Generating gist  ─  7.5 KB written  1m 35s

  Token Usage
  Phase       |   Prompt  |  Completion  |    Total
  Generator   |  144,978  |       1,764  |  146,742

  Post-processing
    1 diagram(s): 1 valid
    4/6 citations valid — 2 file(s) not found

  Done  examples/fastapi/ARCHITECTURE_DOC_gist_*.md  (1m 41s)
```

**Result:** [ARCHITECTURE_DOC_gist_20260319_132212.md](ARCHITECTURE_DOC_gist_20260319_132212.md) — 7.5 KB overview with architecture diagram, tech stack, key components.

---
## Example 2 — Gist (Agent Mode)

**What:** Same gist question, but the agent reads actual files before generating.

**Config:** Same as Example 1 | **Model:** `google/gemini-2.5-flash` | **Mode:** Agent (`--deep`)

```bash
archexa gist --config examples/fastapi/config-gist.yaml --deep
```

**Console Output:**
```
  Codebase Gist  (deep mode)
  Project: ./fastapi

  [1/4] Scanning repository  ─  2,661 files  0.2s
  [2/4] Extracting structural metadata  ─  2661 files | 3842 blocks | 35492 dep edges  4.5s

  [3/4] Investigating codebase
    -- iteration 1
      > list_directory(fastapi/)
      > read_file(fastapi/__init__.py)
      > grep_codebase(app = FastAPI())
      > grep_codebase(Depends)
      > grep_codebase(Middleware)
    -- iteration 2  (6 calls so far)
      [agent summarized findings, continued investigation]
    -- iteration 3  (6 calls so far)
      > read_file(fastapi/applications.py)
      > read_file(fastapi/routing.py)
      > grep_codebase(sqlalchemy|asyncpg|database)
      > grep_codebase(kafka|rabbitmq|celery)
    -- iteration 4  (13 calls so far)
      [agent completed investigation]

  [3/4] Investigating codebase  ─  13 tool calls in 4 iterations  36.9s
  [4/4] Generating document  ─  10.0 KB written  16.6s

  Token Usage
  Phase                            |   Prompt  |  Completion  |    Total
  Investigation  13 calls / 4 iter |   58,107  |       3,890  |   55,370
  Synthesis                        |   47,032  |       2,505  |   49,537
  Total                            |  105,139  |       6,395  |  104,907

  Post-processing
    1 diagram(s): 1 valid
    41/43 citations valid — 2 file(s) not found

  Done  examples/fastapi/ARCHITECTURE_DOC_gist_*_deep.md  (58.3s)
```
**Result:** [ARCHITECTURE_DOC_gist_20260319_132529_deep.md](ARCHITECTURE_DOC_gist_20260319_132529_deep.md) — 10.0 KB with more specific file references from actual code reading.

**Pipeline vs Agent comparison:**

| Response       | Pipeline (Example 1) | Agent (Example 1) |
|----------------|----------------------|-------------------|
| Output size    | 7.5 KB               | 10.0 KB           |
| Time           | 1m 41s               | 58s               |
| Tokens         | 146K                 | 105K              |
| File citations | 6 (4 valid)          | 43 (41 valid)     |
| Diagrams       | 1                    | 1                 |

---

## Example 3 — Analyze (Full Architecture Documentation)

**What:** Comprehensive architecture document using planner + generator pipeline. The planner selects the most important files, then the generator produces a detailed document.

**Config:** [config-analyze.yaml](config-analyze.yaml) | **Model:** `anthropic/claude-sonnet-4` | **Mode:** Pipeline (planner + generator)

```bash
archexa analyze --config examples/fastapi/config-analyze.yaml
```

**Console Output:**
```
  Archexa
  Project: ./fastapi
  Model: anthropic/claude-sonnet-4
  Budget: 198,000 tokens  (16,000 margin)

  [1/5] Scanning repository  ─  2,661 files  0.1s
  [2/5] Extracting evidence  ─  3,842 blocks from 2,661 files | 35492 dep edges  4.4s

  [3/5] Fitting token budget
    #1  279,086 / 182,000  over budget
    shrinking evidence caps...
    #2  149,885 / 182,000  fits

  [3/5] Fitting token budget  ─  149,885 / 182,000 tokens  0.6s
  [4/5] Running selection planner  ─  200 files  47.9s
  [5/5] Generating documentation  ─  10.5 KB written  1m 2s

  Token Usage
  Phase       |   Prompt  |  Completion  |    Total
  Planner     |    4,141  |       3,551  |    7,692
  Generator   |  190,628  |       2,728  |  193,356
  Total       |  194,769  |       6,279  |  201,048

  Post-processing
    6 diagram(s): 6 valid
    All 210 file citations verified

  Done  examples/fastapi/ARCHITECTURE_DOC_*.md  (1m 55s)
```

**Result:** [ARCHITECTURE_DOC_20260319_133342.md](ARCHITECTURE_DOC_20260319_133342.md) — 10.5 KB with 6 mermaid diagrams, 210 verified citations, covering the full FastAPI architecture.

---
## Example 4 — Query Agent (Dependency Injection Deep Dive)

**What:** Targeted deep investigation into how FastAPI's dependency injection system works. The agent reads source files, traces the DI chain, and produces a technical document.

**Config:** [config-query-deep.yaml](config-query-deep.yaml) | **Model:** `anthropic/claude-sonnet-4` | **Mode:** Agent (`--deep`)

```bash
archexa query --config examples/fastapi/config-query-deep.yaml --deep
```

**Console Output:**
```
  Query Analysis  (deep mode)
  Question: How does FastAPI's dependency injection system work?

  [1/4] Scanning repository  ─  2,661 files  0.1s
  [2/4] Extracting structural metadata  ─  2661 files | 3842 blocks  4.5s

  [3/4] Investigating codebase
    -- iteration 1
      > list_directory(fastapi)
      > grep_codebase(dependency|dependencies|Depends)
      > grep_codebase(class.*Depends|def.*Depends)
      > find_references(Depends)
    -- iteration 2  (4 calls)
      > read_file(fastapi/param_functions.py)
      > read_file(fastapi/params.py)
      > read_file(fastapi/dependencies/models.py)
      > read_file(fastapi/dependencies/utils.py)
    ... [13 iterations, 48 tool calls total]
    -- iteration 13  (48 calls)
      [agent completed investigation]

  [3/4] Investigating codebase  ─  48 tool calls in 13 iterations  1m 48s
  [4/4] Generating document  ─  7.5 KB written  38.3s

  Token Usage
  Phase                             |   Prompt  |  Completion  |    Total
  Investigation  48 calls / 13 iter |  226,522  |       5,375  |  231,897
  Synthesis                         |   66,126  |       2,107  |   68,233
  Total                             |  292,648  |       7,482  |  300,130

  Post-processing
    2 diagram(s): 2 valid
    All 18 file citations verified

  Done  examples/fastapi/ARCHITECTURE_DOC_query_*.md  (2m 31s)
```

**Result:** [ARCHITECTURE_DOC_query_20260319_134743.md](ARCHITECTURE_DOC_query_20260319_134743.md) — Detailed DI lifecycle tracing from route definition through dependency resolution to request handling.

---

## Example 5 — Code Review (Agent Mode)

**What:** Architecture-aware security and performance review of the full FastAPI codebase. The agent searches for vulnerabilities, performance issues, and error handling gaps.

**Config:** [config-review.yaml](config-review.yaml) | **Model:** `google/gemini-2.5-flash` | **Mode:** Agent (`--deep`)

```bash
archexa review --config examples/fastapi/config-review.yaml --deep
```

**Console Output:**
```
  Code Review  (deep mode)
  Scope: Full repository

  [1/4] Scanning repository  ─  2,000 files (2,000 in scope)  0.1s
  [2/4] Extracting structural metadata  ─  2000 files | 2460 blocks  3.1s

  [3/4] Investigating codebase
    -- iteration 1
      > list_directory(.)
      > list_directory(fastapi)
      > read_file(fastapi)
    -- iteration 2  (4 calls)
      > read_file(fastapi/__init__.py)
      > read_file(fastapi/applications.py)
      > read_file(fastapi/routing.py)
      > grep_codebase(class.*Exception)
    ... [12 iterations, 48 tool calls total]
    -- iteration 12  (48 calls)
      > read_file(fastapi/exception_handlers.py)
      > grep_codebase(ValidationError)
      > read_file(fastapi/encoders.py)
      > grep_codebase(json\.loads|json\.load)

  [3/4] Investigating codebase  ─  48 tool calls in 12 iterations  1m 8s
  [4/4] Generating document  ─  6.8 KB written  35.0s

  Token Usage
  Phase                             |   Prompt  |  Completion  |    Total
  Investigation  48 calls / 12 iter |  213,599  |       3,546  |  217,145
  Synthesis                         |   56,021  |       1,608  |   57,629
  Total                             |  269,620  |       5,154  |  274,774

  Post-processing
    All 14 file citations verified

  Done  examples/fastapi/ARCHITECTURE_DOC_review_*.md  (1m 46s)
```

**Result:** [ARCHITECTURE_DOC_review_20260319_135353.md](ARCHITECTURE_DOC_review_20260319_135353.md) — Security review with findings table covering vulnerabilities, performance, error handling, and type safety.

---
## Example 6 — Doctor (Setup Diagnostics)

**What:** Validates configuration, API key, endpoint connectivity, and toolchain availability.

```bash
archexa doctor --config examples/fastapi/config-review.yaml
```

**Console Output:**
```
  archexa doctor

  Config file loaded (examples/fastapi/config-review.yaml)
  API key present
  API endpoint unreachable (https://openrouter.ai/api/v1/): ReadTimeout
  Model accessible (google/gemini-2.5-flash)
  Bundle resources present (18 files)
  Output directory writable (examples/fastapi)
  Tree-sitter available (14 languages)
  Tiktoken available (cl100k_base)

  7/8 checks passed
```

Note: The endpoint timeout is expected in some network environments. Doctor helps diagnose exactly which component is failing.

---

## Example 7 — Impact Analysis (Agent Mode)

**What:** Analyzes what would break if you add a rate limiting parameter to FastAPI's route decorators. Traces reverse dependencies, transitive impact, and affected test files.

**Config:** [config-impact.yaml](config-impact.yaml) | **Model:** `openai/gpt-4.1` | **Mode:** Agent (`--deep`)

```bash
archexa impact --config examples/fastapi/config-impact.yaml --deep
```

**Console Output:**
```
  Impact Analysis  (deep mode)
  Target: fastapi/routing.py
  Query:  Changing the route decorator to support a new parameter for rate limiting

  [1/5] Scanning repository  ─  2,661 files  0.1s

    Symbols extracted: 165
    Classes/types: APIRoute, APIRouter, APIWebSocketRoute, Item...
    Methods: __call__, __init__, _async_stream_jsonl...

  [2/5] Analyzing target symbols  ─  165 symbols | 1735 files reference them  4.7s
  [3/5] Extracting evidence & tracing impact  ─  1042 dep-affected + 1735 symbol-refs | risk: HIGH  6.8s

    Direct dependents (25):
      > docs_src/custom_request_and_route/tutorial001_an_py310.py
      > tests/test_custom_route_class.py
      > tests/test_generate_unique_id_function.py
      ... and 15 more
    Symbol references (1735):
      > fastapi/applications.py
      > fastapi/param_functions.py
      > fastapi/openapi/utils.py
      ... and 1725 more
    Transitive (1017):
      > docs_src/additional_responses/tutorial001_py310.py
      ... and 1012 more

  [4/5] Investigating codebase
    -- iteration 1
      > list_directory(fastapi/)
      > grep_codebase(import .*routing|from .*routing import)
      > grep_codebase(def (get|post|put|delete|patch|route)\()
      > grep_codebase(rate_limit|ratelimit|rateLimit)
    ... [7 iterations, 28 tool calls total]

  [4/5] Investigating codebase  ─  28 tool calls in 7 iterations  1m 18s
  [5/5] Generating document  ─  12.4 KB written  1m 20s

  Token Usage
  Phase                            |   Prompt  |  Completion  |    Total
  Investigation  28 calls / 7 iter |  130,924  |       1,983  |  101,931
  Synthesis                        |   54,812  |       2,512  |   57,324
  Total                            |  185,736  |       4,495  |  159,255

  Estimated cost: $0.41

  Post-processing
    1 diagram(s): 1 valid
    27/28 citations valid — 1 file(s) not found

  Done  examples/fastapi/ARCHITECTURE_DOC_impact_*.md  (2m 50s)
```

**Result:** [ARCHITECTURE_DOC_impact_20260319_143105.md](ARCHITECTURE_DOC_impact_20260319_143105.md) — 12.4 KB impact analysis with dependency diagram, affected files table, risk assessment, testing scope, and migration steps.

---
## Summary

| # | Command | Mode | Model | Time | Tokens | Cost | Output |
|---|---------|------|-------|------|--------|------|--------|
| 1 | `gist` | Pipeline | gemini-2.5-flash | 1m 41s | 147K | ~$0.02 | 7.5 KB |
| 2 | `gist --deep` | Agent | gemini-2.5-flash | 58s | 105K | ~$0.02 | 10.0 KB |
| 3 | `analyze` | Pipeline | claude-sonnet-4 | 1m 55s | 201K | ~$0.60 | 10.5 KB |
| 4 | `query --deep` | Agent | claude-sonnet-4 | 2m 31s | 300K | ~$0.90 | 7.5 KB |
| 5 | `review --deep` | Agent | gemini-2.5-flash | 1m 46s | 275K | ~$0.04 | 6.8 KB |
| 6 | `doctor` | — | — | instant | — | $0 | diagnostics |
| 7 | `impact --deep` | Agent | gpt-4.1 | 2m 50s | 159K | ~$0.41 | 12.4 KB |

All examples run against the same FastAPI repository (2,661 files). Generated documents are committed alongside the configs for reference.
