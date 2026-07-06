# Path-Specific Rules

> **How these are applied.** Claude Code does **not** auto-load path-scoped rule
> files. These rules take effect through two mechanisms in this template:
> (1) the path-scoped **agents** (gameplay-programmer, engine-programmer, etc.)
> carry the relevant standards in their own prompts, and (2) skills like
> `/code-review` and `/dev-story` read the matching rule file for the code under
> review. To make a rule load automatically while editing a subtree, add a
> directory-scoped `CLAUDE.md` there that `@`-imports it (e.g.
> `src/gameplay/CLAUDE.md` containing `@../../.claude/rules/gameplay-code.md`) —
> Claude Code loads a directory's `CLAUDE.md` on demand when you work in it.

The rule files and the paths they govern:

| Rule File | Path Pattern | Enforces |
| ---- | ---- | ---- |
| `gameplay-code.md` | `src/gameplay/**` | Data-driven values, delta time, no UI references |
| `engine-code.md` | `src/core/**` | Zero allocs in hot paths, thread safety, API stability |
| `ai-code.md` | `src/ai/**` | Performance budgets, debuggability, data-driven params |
| `network-code.md` | `src/networking/**` | Server-authoritative, versioned messages, security |
| `ui-code.md` | `src/ui/**` | No game state ownership, localization-ready, accessibility |
| `design-docs.md` | `design/gdd/**` | Required 8 sections, formula format, edge cases |
| `narrative.md` | `design/narrative/**` | Lore consistency, character voice, canon levels |
| `data-files.md` | `assets/data/**` | JSON validity, naming conventions, schema rules |
| `test-standards.md` | `tests/**` | Test naming, coverage requirements, fixture patterns |
| `prototype-code.md` | `prototypes/**` | Relaxed standards, README required, hypothesis documented |
| `shader-code.md` | `assets/shaders/**` | Naming conventions, performance targets, cross-platform rules |
