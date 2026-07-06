# Agent Coordination Rules

1. **Vertical Delegation**: Leadership agents delegate to department leads, who
   delegate to specialists. Never skip a tier for complex decisions.
2. **Horizontal Consultation**: Agents at the same tier may consult each other
   but must not make binding decisions outside their domain.
3. **Conflict Resolution**: When two agents disagree, escalate to the shared
   parent. If no shared parent, escalate to `creative-director` for design
   conflicts or `technical-director` for technical conflicts.
4. **Change Propagation**: When a design change affects multiple domains, the
   `producer` agent coordinates the propagation.
5. **No Unilateral Cross-Domain Changes**: An agent must never modify files
   outside its designated directories without explicit delegation.

## Model Tier Assignment

The studio is built to run with **Opus as the main session model** (pinned via
`"model": "opus"` in `.claude/settings.json`, currently `claude-opus-4-8`).
Agents and skills are tiered so quality-critical roles stay on Opus even if the
session model is changed:

| Tier | `model:` value | Who | Rationale |
|------|----------------|-----|-----------|
| **Directors & Leads** | `opus` (pinned) | creative-director, technical-director, producer + all 8 department leads | Gate verdicts and cross-system judgment stay on the strongest model regardless of session settings |
| **Specialists** | `inherit` | all other agents | Follow the session model — Opus when you run Opus, cheaper if you deliberately downgrade the session |
| **Mechanical skills** | `haiku` | `/help`, `/sprint-status`, `/scope-check`, `/project-stage-detect`, `/changelog`, `/patch-notes`, `/onboard` | Read-and-format work; no judgment needed |
| **Gate skills** | `opus` (pinned) | `/review-all-gdds`, `/architecture-review`, `/gate-check` | High-stakes verdicts |
| **External workers** | Nemotron Orchestra MCP | bulk drafting only — see @external-models.md | Cheap draft labor; Claude reviews everything |

All other skills carry no `model:` field and inherit the session model. When
creating new skills: assign `haiku` if the skill only reads and formats; pin
`opus` only for phase-gate verdicts; otherwise leave unset.

Bulk generation (lore drafts, localization passes, boilerplate, reverse-docs)
can be offloaded to external models — rules and quality gate in
`.claude/docs/external-models.md`.

## Subagents vs Agent Teams

This project uses two distinct multi-agent patterns:

### Subagents (current, always active)
Spawned via `Task` within a single Claude Code session. Used by all `team-*` skills
and orchestration skills. Subagents share the session's permission context, run
sequentially or in parallel within the session, and return results to the parent.

**When to spawn in parallel**: If two subagents' inputs are independent (neither
needs the other's output to begin), spawn both Task calls simultaneously rather
than waiting. Example: `/review-all-gdds` Phase 1 (consistency) and Phase 2
(design theory) are independent — spawn both at the same time.

### Agent Teams (experimental — opt-in)
Multiple independent Claude Code *sessions* running simultaneously, coordinated
via a shared task list. Each session has its own context window and token budget.
Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` environment variable.

**Use agent teams when**:
- Work spans multiple subsystems that will not touch the same files
- Each workstream would take >30 minutes and benefits from true parallelism
- A senior agent (technical-director, producer) needs to coordinate 3+ specialist
  sessions working on different epics simultaneously

**Do not use agent teams when**:
- One session's output is required as input for another (use sequential subagents)
- The task fits in a single session's context (use subagents instead)
- Cost is a concern — each team member burns tokens independently

**Current status**: Opt-in via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Document first usage here when adopted.

## Parallel Task Protocol

When an orchestration skill spawns multiple independent agents:

1. Issue all independent Task calls before waiting for any result
2. Collect all results before proceeding to dependent phases
3. If any agent is BLOCKED, surface it immediately — do not silently skip
4. Always produce a partial report if some agents complete and others block
