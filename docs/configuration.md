# Configuration Reference

Archexa is configured via a YAML file (default: `archexa.yaml`). Run `archexa init` to generate a starter config.

---

## Full Example

```yaml
project:
  base_path: .
  entry_files: []

llm:
  model: gpt-4o
  base_url: https://api.openai.com/v1
  ssl_verify: true

limits:
  max_files: 100
  max_prompt_tokens: 128000
  safety_margin: 16000

evidence:
  max_bytes_per_file: 300000
  max_blocks_per_file: 12
  block_lines: 120
  context_before: 10
  context_after: 90
  max_focused_slices: 20

output:
  out: generated
  show_evidence_summary: false
  include_evidence_in_markdown: true

logging:
  level: WARNING

prompts:
  user_prompt: ""
  gist_prompt: ""
  query_prompt: ""
  impact_prompt: ""
  review_prompt: ""

query:
  question: ""
  target: ""

service:
  focus: []

analyze:
  max_attempts: 5

agent:
  enabled: false
  max_iterations: 15

cache:
  enabled: true
```

---

## Section Reference

### `project`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `base_path` | string | `.` | Root of the repository to analyze (relative to config file) |
| `entry_files` | list | `[]` | Specific entry point files. Empty = scan entire repo |

### `llm`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `model` | string | **required** | Model identifier (e.g. `gpt-4o`, `claude-sonnet-4-20250514`) |
| `base_url` | string | **required** | API endpoint URL |
| `ssl_verify` | bool | `true` | Set `false` for self-signed certs |

**Environment variables for API keys:**

| Provider | Variable |
|----------|----------|
| OpenAI | `OPENAI_API_KEY` |
| Azure OpenAI | `AZURE_OPENAI_API_KEY` |
| OpenRouter | `OPENAI_API_KEY` (with `sk-or-` prefix) |

### `limits`

| Field | Type | Default | Range | Description |
|-------|------|---------|-------|-------------|
| `max_files` | int | `100` | >= 1 | Maximum files to include in analysis |
| `max_prompt_tokens` | int | `128000` | >= 10,000 | Token budget for LLM prompt (match your model's context window) |
| `safety_margin` | int | `16000` | >= 0 | Tokens reserved for LLM response output |

### `evidence`

Controls how source code is parsed and sampled.

| Field | Type | Default | Range | Description |
|-------|------|---------|-------|-------------|
| `max_bytes_per_file` | int | `300000` | >= 10,000 | Skip files larger than this |
| `max_blocks_per_file` | int | `12` | >= 1 | Max evidence blocks per file |
| `block_lines` | int | `120` | >= 10 | Lines per evidence block |
| `context_before` | int | `10` | >= 0 | Context lines before a match |
| `context_after` | int | `90` | >= 0 | Context lines after a match |
| `max_focused_slices` | int | `20` | >= 0 | Max function-level code slices |

### `output`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `out` | string | `generated` | Output directory or file path |
| `show_evidence_summary` | bool | `false` | Print evidence summary table in console |
| `include_evidence_in_markdown` | bool | `true` | Include E# references in output |

### `logging`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `level` | string | `WARNING` | Log level: `DEBUG`, `INFO`, `WARNING`, `ERROR` |

### `prompts`

Optional natural-language instructions appended to each command's LLM prompt. Use these to steer focus, format, or depth.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `user_prompt` | string | `""` | Used by `analyze` command |
| `gist_prompt` | string | `""` | Used by `gist` command |
| `query_prompt` | string | `""` | Used by `query` command |
| `impact_prompt` | string | `""` | Used by `impact` command |
| `review_prompt` | string | `""` | Used by `review` command |

**Example:**
```yaml
prompts:
  user_prompt: "Focus on database query patterns and API security."
  gist_prompt: "Include information about the deployment architecture."
```

### `query`

Default values for the `query` and `impact` commands. CLI flags override these.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `question` | string | `""` | Default question for `archexa query` |
| `target` | string | `""` | Default target for `archexa impact` (comma-separated) |

### `service`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `focus` | list | `[]` | Limit analysis to specific directories/services. Empty = scan everything |

**Example:**
```yaml
service:
  focus:
    - order-service
    - payment-service
```

### `analyze`

| Field | Type | Default | Range | Description |
|-------|------|---------|-------|-------------|
| `max_attempts` | int | `5` | >= 1 | Retry attempts for adaptive token budget fitting |

### `agent`

Controls the agentic investigation loop used by the `--deep` flag.

| Field | Type | Default | Range | Description |
|-------|------|---------|-------|-------------|
| `enabled` | bool | `false` | — | Always use deep mode (same as `--deep`) |
| `max_iterations` | int | `15` | 1-50 | Max tool-calling rounds in investigation |

### `cache`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | bool | `true` | Cache evidence extraction in `.archexa_cache/`. Use `--fresh` to bypass |
