# Skill Test Spec: /vertical-slice

## Skill Summary

`/vertical-slice` runs the Pre-Production validation gate: it drives building a
production-quality, end-to-end slice that proves the full game loop is achievable
before committing to Production. It runs after GDDs, architecture, and UX specs
are complete, and produces a PROCEED / PIVOT / KILL verdict that gates the
Pre-Production → Production transition.

The skill asks before writing its report and (in full review mode) spawns director
gates for sign-off. Verdicts: PROCEED (loop proven — advance to Production),
PIVOT (loop needs rework before Production), KILL (core loop is not viable).

---

## Static Assertions (Structural)

Verified automatically by `/skill-test static` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Does NOT declare an unsupported `isolation:` frontmatter field
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: PROCEED, PIVOT, KILL (and no stray STOP verdict)
- [ ] Contains "May I write" language before writing the report
- [ ] References the vertical-slice-report template or an equivalent report structure

---

## Director Gate Checks

In `full` review mode the skill spawns director gates for the Production readiness
decision (creative + technical + producer). In `lean`/`solo` mode these are skipped
with a logged note. Gate IDs used must exist in `.claude/docs/director-gates.md`.

---

## Test Cases

### Case 1: Happy Path — Loop proven, PROCEED

**Fixture:**
- GDDs, architecture, and UX specs exist and are approved
- A buildable slice covering the core loop

**Input:** `/vertical-slice`

**Expected behavior:**
1. Skill confirms prerequisites (GDDs, architecture, UX) exist
2. Drives the end-to-end slice build covering the full core loop
3. Produces a vertical-slice report (what was built, what the loop proved, risks)
4. Asks "May I write this report to ...?" before writing
5. Verdict is PROCEED

**Assertions:**
- [ ] Prerequisite check runs before the build
- [ ] Report captures the full loop, not an isolated mechanic
- [ ] "May I write" confirmation precedes the report write
- [ ] Verdict is PROCEED

---

### Case 2: Loop incomplete — PIVOT

**Fixture:**
- Slice reveals the loop is not yet fun/coherent but is salvageable

**Input:** `/vertical-slice`

**Expected behavior:**
1. Report documents the specific loop weaknesses
2. Recommendation: rework named systems before Production
3. Verdict is PIVOT

**Assertions:**
- [ ] Report names concrete loop weaknesses (not vague)
- [ ] Verdict is PIVOT (not PROCEED)
- [ ] A rework path is proposed before advancing

---

### Case 3: Core loop not viable — KILL

**Fixture:**
- Slice shows the core loop cannot be made to work within scope

**Input:** `/vertical-slice`

**Expected behavior:**
1. Report documents why the loop is not viable
2. Verdict is KILL
3. Skill does NOT advance the project stage to Production

**Assertions:**
- [ ] Verdict is KILL
- [ ] Failure reasons are specific
- [ ] No stage advance to Production occurs

---

### Case 4: Review-mode gating — lean/solo skip director gates

**Fixture:**
- `production/review-mode.txt` set to `lean`

**Input:** `/vertical-slice --review lean`

**Expected behavior:**
1. Director gates are skipped with a logged note (e.g. "… skipped — Lean mode")
2. The slice build and verdict still complete

**Assertions:**
- [ ] Director gate spawns are skipped in lean/solo
- [ ] A skip note is recorded
- [ ] A verdict is still produced

---

### Case 5: Full-mode director sign-off

**Fixture:**
- `production/review-mode.txt` set to `full`

**Input:** `/vertical-slice --review full`

**Expected behavior:**
1. Skill spawns the Production-readiness director gates
2. Gate IDs used exist in `.claude/docs/director-gates.md`
3. Verdict integrates the gate outcomes

**Assertions:**
- [ ] Director gates are spawned in full mode
- [ ] Every gate ID used is defined in director-gates.md
- [ ] Verdict reflects the gate verdicts

---

## Protocol Compliance

- [ ] Confirms prerequisites (GDDs, architecture, UX) before building
- [ ] Asks "May I write" before writing the report
- [ ] Verdict is one of PROCEED / PIVOT / KILL
- [ ] Respects review mode for director-gate spawning
- [ ] Does not advance the stage on PIVOT or KILL

---

## Coverage Notes

- The actual playability of the built slice is validated by playtesting, not by
  this spec — the spec checks the skill's process and verdict handling.
- Engine-specific build scaffolding follows the same flow with engine-appropriate
  file types.
