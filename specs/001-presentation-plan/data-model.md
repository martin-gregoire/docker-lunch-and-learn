# Data Model: Presentation Plan Document

**Phase**: 1 — Design
**Date**: 2026-07-30
**Feature**: [spec.md](spec.md) · [research.md](research.md)

---

## Entity Overview

```
PlanDocument
├── ApplicationOverview
│   └── Component[]
├── Outline
│   └── Section[]
└── DemosCatalogue
    └── Demo[]
        └── Step[]
```

---

## Entities

### PlanDocument

The top-level document (`presentation/PLAN.md`).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | ✅ | E.g., "Docker & Containerization — Lunch and Learn" |
| `target_duration` | string | ✅ | E.g., "~55 minutes" |
| `audience` | string | ✅ | E.g., "Software Developers & Quality Engineers" |
| `last_updated` | date | ✅ | ISO 8601 date of last plan update |
| `application_overview` | ApplicationOverview | ✅ | Description of the sample app |
| `outline` | Outline | ✅ | Ordered list of all session sections |
| `demos_catalogue` | DemosCatalogue | ✅ | All demo checkpoints in session order |

---

### ApplicationOverview

Describes the sample application used across all demo checkpoints. Must be self-contained so any presenter understands what is being built (FR-012).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `app_name` | string | ✅ | Short name used in demo commands (e.g., `lunchdemo`) |
| `description` | string | ✅ | 2–4 sentence description of what the app does |
| `components` | Component[] | ✅ | Min 2, max 5 components |
| `teaching_rationale` | string | ✅ | Why this app was chosen as a teaching vehicle |
| `source_location` | string | ✅ | Repo path to the app source (e.g., `demo/`) |

---

### Component

One service/tier of the sample application.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | ✅ | E.g., "nginx frontend", "Python API", "PostgreSQL" |
| `image_or_dockerfile` | string | ✅ | E.g., `nginx:1.27-alpine` or `demo/api/Dockerfile` |
| `role` | string | ✅ | One sentence explaining the component's responsibility |
| `docker_concept_introduced` | string | ✅ | Which Docker concept this component first demonstrates (e.g., "pulling a pre-built image", "building a custom image", "named volumes") |

---

### Outline

The primary planning artifact. Independently readable and shareable without the Demos section (FR-003, FR-007).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `sections` | Section[] | ✅ | Ordered list; must match the section order in `slides.md` |

**Invariant**: `sum(section.estimated_duration_min)` must be within the 55–70 minute session window.

---

### Section

One logical block of the presentation.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `number` | integer | ✅ | 1-based sequential index |
| `title` | string | ✅ | Display title (matches slide heading) |
| `teaching_goal` | string | ✅ | One sentence: what the audience understands after this section |
| `estimated_duration_min` | integer | ✅ | Presenter's time estimate in minutes |
| `slides_reference` | string | ✅ | E.g., "slides 5–8" or "new slide needed" |
| `demo` | DemoRef \| "No demo" \| "Demo deferred to §N" | ✅ | Must always be explicitly stated (FR-009) |

**Constraint**: `demo` field must never be blank or omitted — the absence of a demo must be explicit.

---

### DemoRef

A reference from a Section to a Demo in the catalogue.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `checkpoint_number` | integer | ✅ | Matches `Demo.number` |
| `label` | string | ✅ | E.g., "Demo checkpoint 1 — Build the API image" |

---

### DemosCatalogue

The operational reference for presenters during session delivery.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `demos` | Demo[] | ✅ | Ordered by session appearance; checkpoint numbers are sequential |

---

### Demo

A runnable demo checkpoint. Each demo leaves the system in a defined state that the next demo inherits (FR-011).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `number` | integer | ✅ | 1-based; matches `DemoRef.checkpoint_number` |
| `name` | string | ✅ | Short display name (e.g., "Build the Python API image") |
| `section_number` | integer | ✅ | Which Section this demo belongs to |
| `concept_illustrated` | string | ✅ | The primary Docker/K8s concept demonstrated |
| `inherited_state` | string | ✅ | System state left by the previous demo; "None — clean install" for Demo 1 |
| `prerequisites` | string[] | ✅ | Min 1 entry; must include tool versions |
| `steps` | Step[] | ✅ | Ordered; each step independently executable |
| `fallback` | string | ✅ | What to do if the demo fails live (FR-005) |
| `resulting_state` | string | ✅ | System state left for the next demo to inherit |

---

### Step

One atomic action within a demo.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | string | ✅ | Audience-facing explanation of what this step does |
| `command` | string \| null | — | The exact CLI command to run; null for explanation-only steps |
| `expected_output` | string \| null | — | What the presenter (and audience) should see after running |
