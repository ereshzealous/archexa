# Deep Mode (Agentic Investigation)

Deep mode (`--deep`) enables an agentic investigation loop that autonomously explores your codebase before generating documentation. This produces significantly more thorough and accurate results.

---

## How It Works

### Phase 1: Investigation

The agent receives a repository overview (file tree, detected interfaces, class hierarchy, call graphs) and then autonomously:

1. **Reads key files** — entry points, service classes, handlers, models
2. **Greps for patterns** — HTTP routes, event handlers, database queries, configuration
3. **Traces imports** — follows dependency chains across packages
4. **Finds symbol references** — tracks where classes and functions are used

The agent decides what to investigate next based on what it has learned so far. It continues for multiple iterations until it has gathered enough information (or hits the configured `max_iterations`).

### Phase 2: Synthesis

After investigation, the agent generates the final document using:
- **Structured evidence** from static analysis (AST parsing, interface detection)
- **Investigation findings** from the autonomous exploration phase

Both sources are combined for maximum depth and accuracy.

---

## When to Use Deep Mode

| Scenario | Standard | Deep |
|----------|----------|------|
| Small project (< 50 files) | Good enough | Overkill |
| Medium project (50-200 files) | Usually fine | Better for complex architecture |
| Large project (200+ files) | May miss details | Recommended |
| Microservices / event-driven | Misses cross-service flows | Catches communication patterns |
| Monolith with clear structure | Works well | Marginal benefit |
| Legacy / undocumented codebase | Struggles | Significantly better |

---

## Adaptive Scaling

Archexa automatically scales investigation depth based on repository size:

| Repo Size | Max Iterations | Min Tool Calls | Context Budget |
|-----------|---------------|----------------|----------------|
| ~50 files | 5 | 3 | 40K tokens |
| ~500 files | 10 | 8 | 80K tokens |
| ~5,000 files | 14 | 11 | 110K tokens |
| 10,000+ files | 15 | 12 | 120K tokens |

This ensures small repos aren't over-investigated and large repos get thorough coverage.

---

## Configuration

```yaml
agent:
  enabled: false       # Set true to always use deep mode
  max_iterations: 15   # Max investigation rounds (1-50)
```

Or use the CLI flag:

```bash
archexa analyze --config archexa.yaml --deep
archexa gist --config archexa.yaml --deep
archexa query --config archexa.yaml --query "How does auth work?" --deep
```

---

## Token Usage

Deep mode uses more API tokens than standard mode:

- **Investigation phase**: Multiple LLM calls with tool use (typically 5-15 iterations)
- **Synthesis phase**: One streaming LLM call to generate the document

The total token cost depends on repository size and complexity. For a medium project (~200 files), expect roughly 3-5x the tokens of standard mode.

---

## Context Management

During investigation, Archexa manages the conversation context to stay within token budgets:

- **Progressive pruning** — older tool results are compressed each iteration
- **Evidence deduplication** — files already read aren't re-sent in grep results
- **Adaptive compression** — when approaching the budget limit, older results are summarized

This allows deep investigation of large codebases without exceeding model context windows.
