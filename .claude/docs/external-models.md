# External Model Offload (Nemotron Orchestra)

This studio can offload bulk generation work to external models through the
`nemotron-orchestra` MCP server (registered in `~/.claude.json`, user scope).
Claude stays the orchestrator and quality gate; external models are cheap,
fast drafting labor.

## Available Workers

| Alias | Model | Best for |
|-------|-------|----------|
| `ultra` | nvidia/nemotron-3-ultra-550b-a55b | Default. Heavy reasoning drafts, large docs |
| `kimi` | moonshotai/kimi-k2.6 | Code drafts, creative prose, lore/dialogue bulk |
| `fast` | nvidia/nemotron-3-super-120b-a12b | Mechanical bulk: boilerplate, tables, format conversion |
| `reasoner2` | z-ai/glm-5.2 | Second-opinion reviews, alternative analysis |
| `vision` | nvidia/nemotron-3-nano-omni-30b-a3b-reasoning | Image-input tasks |

## Tools

- `mcp__nemotron-orchestra__nemotron_generate` — short outputs returned into
  context (plans, reviews, snippets). Response consumes context; keep it small.
- `mcp__nemotron-orchestra__nemotron_write_file` — worker generates a file
  straight to disk; only a summary enters context. **The main token saver.**
- `mcp__nemotron-orchestra__nemotron_revise_file` — worker rewrites an existing
  file per instructions without pulling it through context.
- `mcp__nemotron-orchestra__nemotron_models` / `nemotron_health` — discovery/status.

## When to Offload

Offload when ALL of these hold:

1. The output is **bulk** (hundreds of lines) and **draft-quality is acceptable**
   as a starting point.
2. The task is **specification-driven** — you can state the requirements
   completely in the prompt (the worker has no conversation context).
3. Claude will **review the result before it counts** (see quality gate below).

Good offload targets:

- First-draft localization passes across many strings (`kimi` or `fast`)
- Lore/flavor-text bulk drafts: item descriptions, NPC barks, codex entries (`kimi`)
- Boilerplate/scaffold code and data tables the design already fully specifies (`kimi`/`fast`)
- Reverse-documentation drafts of large existing source files (`fast`)
- Format conversions and mechanical rewrites of large docs (`fast`)

Do NOT offload:

- Anything touching architecture, pillars, or design decisions
- Gate verdicts, reviews that block progress, security-sensitive code
- Small tasks (< ~100 lines) — orchestration overhead exceeds the savings
- Tasks needing project context the prompt can't carry compactly

## Quality Gate (mandatory)

External output is a **draft**, never a deliverable:

1. Prompt the worker with the complete spec (include naming conventions,
   engine version, target directory conventions in `extra_context`).
2. After `nemotron_write_file`/`nemotron_revise_file`, **read the file back**
   and check it against the spec and the project's rules.
3. Fix defects yourself with Edit, or send one `nemotron_revise_file` round,
   then re-check. Never loop revisions more than twice — take over instead.
4. The file counts as done only after Claude's review, like any other code
   (normal `/code-review` and story gates still apply).

## Cost/Latency Note

Workers run on NVIDIA's API with the user's key. They are slower per call than
local edits but keep Opus context free for orchestration. Batch related work
into one `nemotron_write_file` call per file rather than many small calls.
