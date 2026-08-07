# Contract: PLAN.md Format

**Phase**: 1 — Design
**Date**: 2026-07-30
**Feature**: [spec.md](../spec.md) · [data-model.md](../data-model.md)

This document defines the exact Markdown structure that `presentation/PLAN.md` must follow.
Any author or tool generating PLAN.md must conform to this contract.

---

## File Location

```
presentation/PLAN.md
```

---

## Top-Level Structure

```markdown
# [Session Title]

**Target Duration**: ~55 minutes
**Audience**: Software Developers & Quality Engineers
**Last Updated**: YYYY-MM-DD

---

## Application Overview

[2–4 sentence description of the demo app]

### Components

| Component | Image / Source | Role | Docker concept |
|-----------|---------------|------|----------------|
| nginx frontend | `nginx:1.27-alpine` | ... | ... |
| Python API | `demo/api/Dockerfile` | ... | ... |
| PostgreSQL | `postgres:16-alpine` | ... | ... |

**Source**: `demo/`

**Why this app?** [1–2 sentences on teaching rationale]

---

## Part 1 — Outline

> This section is the primary planning artifact. It can be shared independently.

### Section 1 — [Title]

**Teaching goal**: [One sentence — what the audience understands after this section]
**Duration**: N min
**Slides**: [e.g., slides 3–4 or "new slide needed"]
**Demo**: No demo

**Slide content**:
- [Talking point 1 — one sentence, audience-facing]
- [Talking point 2]
- [Talking point 3]
(3–5 bullets; suggestions only — final slide wording is the implementer’s responsibility)

**References**:
- [Authoritative source title](https://url) — one-line description of what it covers

**Media**:
- [use] [Title](https://url) — existing official diagram/image that can be embedded directly in the slide
- [create] [Description of custom visual to be authored] — e.g., "ASCII side-by-side diagram of X vs Y"

---

### Section 2 — [Title]

**Teaching goal**: [One sentence]
**Duration**: N min
**Slides**: [...]
**Demo**: No demo

**Slide content**:
- [Talking point 1]
- [Talking point 2]
- [Talking point 3]

**References**:
- [Authoritative source title](https://url) — one-line description

**Media**:
- [create] [Description of custom visual to be authored]

---

### Section N — [Title]

**Teaching goal**: [One sentence]
**Duration**: N min
**Slides**: [...]
**Demo**: Demo checkpoint N — [short label]

**Slide content**:
- [Talking point 1]
- [Talking point 2]
- [Talking point 3]

**References**:
- [Authoritative source title](https://url) — one-line description

**Media**:
- [use] [Title](https://url) — existing official diagram/image
- [create] [Description of custom visual to be authored]

---

| Section | Duration | Demo |
|---------|----------|------|
| 1. [Title] | N min | No demo |
| 2. [Title] | N min | No demo |
| ... | | |
| **Total** | **~NN min** | |

---

## Part 2 — Demos

> Operational reference for presenters. Each checkpoint builds on the previous one.

### Demo Checkpoint 1 — [Name]

**Section**: N — [Section Title]
**Concept illustrated**: [Primary Docker/K8s concept]
**Inherited state**: None — clean Docker install

**Prerequisites**:
- Docker Engine ≥ 26 (`docker --version`)
- [Any other tool + version]

**Steps**:

1. **[Step description]**
   ```bash
   [command]
   ```
   Expected: [what to see]

2. **[Step description]**
   ```bash
   [command]
   ```

**Fallback**: [What to do if this fails live]

**Resulting state**: [What the system looks like after this demo — what Demo 2 inherits]

---

### Demo Checkpoint 2 — [Name]

**Section**: N — [Section Title]
**Concept illustrated**: [Primary concept]
**Inherited state**: [What Demo 1 left behind]

**Prerequisites**:
- [Inherited from Demo 1 — no reinstall needed]
- [Any additional prerequisites]

**Steps**:

1. ...

**Fallback**: ...

**Resulting state**: ...

---

[Repeat for all checkpoints]
```

---

## Field Rules

| Field | Rule |
|-------|------|
| `**Teaching goal**` | Exactly one sentence; starts with "Audience …" or describes what attendees will be able to do |
| `**Duration**` | Integer minutes; no ranges |
| `**Slides**` | Either "slides N–M", "slide N", or "new slide needed" |
| `**Demo**` | MUST be present on every Section; value is "No demo", "Demo deferred to §N — [reason]", or "Demo checkpoint N — [label]" |
| `**Slide content**` | 3–5 bullet talking points the slide must cover; suggestions only — final wording is the implementer's responsibility; MUST be present on every Section except §12 (Q&A) |
| `**References**` | One or more links to authoritative sources (official docs, specs, RFCs); each entry is `[Title](url) — one-line description`; MUST be present on every Section except §12 (Q&A) |
| `**Media**` | One or more media entries, each prefixed with either `[use]` or `[create]`: `[use]` links to an existing official diagram/image that can be embedded directly; `[create]` describes a custom visual that must be authored for the slide; MUST be present on every Section except §12 (Q&A); may contain only `[create]` entries, only `[use]` entries, or both |
| `**Inherited state**` | First checkpoint: "None — clean Docker install"; subsequent: describe concrete artifacts left behind |
| `**Resulting state**` | Describe concrete artifacts/running services; must map to next checkpoint's `Inherited state` |
| `**Fallback**` | Must be actionable (e.g., "Show pre-recorded `docker ps` output" not "skip the demo") |
| Commands | All commands in fenced `bash` blocks; no `$` prompt prefix |
| Prerequisites | Each prerequisite includes tool name, minimum version, and verification command |

---

## Validation Checklist

Before committing a change to `PLAN.md`:

- [ ] Every Section block has all eight fields: Teaching goal, Duration, Slides, Demo, Slide content, References, Media (§12 Q&A is exempt from Slide content, References, and Media)
- [ ] No Section's `Demo` field is blank or missing
- [ ] Outline summary table totals match the sum of individual section durations
- [ ] Every `Demo checkpoint N` reference in the Outline has a matching `### Demo Checkpoint N` entry in Part 2
- [ ] Every Demo has: Concept, Inherited state, Prerequisites (≥1), Steps (≥1), Fallback, Resulting state
- [ ] `Resulting state` of Demo N matches `Inherited state` of Demo N+1
- [ ] All commands are in fenced `bash` blocks and were tested end-to-end
- [ ] `Last Updated` date is current
