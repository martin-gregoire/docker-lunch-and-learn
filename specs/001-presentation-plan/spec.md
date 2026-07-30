# Feature Specification: Presentation Plan Document

**Feature Branch**: `001-presentation-plan`

**Created**: 2026-07-30

**Status**: Draft

**Input**: User description: "I think we should have a presentation plan aside from the actual slides that will contain the outline, information about what will be presented, and also outline what we will demo along the presentation"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Presenter Reviews Full Outline Before Session (Priority: P1)

A presenter opening the plan document for the first time gets an end-to-end view of the entire session: every topic in order, the intent behind each section, and where each demo fits in the flow. They can mentally rehearse the session without opening the slides.

**Why this priority**: This is the core value of the plan. Every other story depends on having this consolidated view. Without it, the presenter must reconstruct the session flow by reading through the full slide deck.

**Independent Test**: Can be fully tested by opening the plan document and confirming that a reader with no prior knowledge of the session can reconstruct the session order, topic intent, and demo points from the plan alone — without consulting `slides.md`.

**Acceptance Scenarios**:

1. **Given** a presenter opens the plan document, **When** they read the outline section, **Then** they see every major section and subsection in the order they appear in the presentation, matching the agenda in the slides.
2. **Given** a presenter reads any section entry in the outline, **When** they look at its description, **Then** they understand the teaching goal of that section (what the audience should learn or take away).
3. **Given** a presenter reads the plan, **When** they encounter a demo entry, **Then** they can identify exactly which point in the session the demo occurs, what will be demonstrated, and the prerequisites needed to run it.

---

### User Story 2 - Presenter Locates Demo Instructions During Session (Priority: P2)

Mid-session, the presenter needs to quickly find what to demo next and any commands or setup steps required, without scrolling through the slide deck.

**Why this priority**: Demos are high-stakes moments. Having them consolidated and easy to find reduces cognitive load and the risk of mistakes in front of an audience.

**Independent Test**: Can be fully tested by simulating a live session: given only the plan document and a terminal, a presenter can execute every demo in sequence without referring to the slides.

**Acceptance Scenarios**:

1. **Given** a demo is about to begin, **When** the presenter consults the plan, **Then** they see the demo name, its position in the flow, what concept it illustrates, and the exact steps or commands required.
2. **Given** a demo has a prerequisite (tool version, running service, prior step), **When** the presenter reads the demo entry, **Then** the prerequisite is explicitly listed.
3. **Given** a demo can fail gracefully, **When** the presenter reads the demo entry, **Then** a fallback or recovery note is included.

---

### User Story 3 - New Presenter Onboards to the Session (Priority: P3)

A team member who did not create the session can pick up the plan document and deliver the session without prior briefing from the original author.

**Why this priority**: Ensures the session is transferable and reduces bus-factor dependency on the original presenter.

**Independent Test**: Can be fully tested by having a new team member read only the plan document and confirm they could deliver the session from it, asking zero questions of the original author.

**Acceptance Scenarios**:

1. **Given** a new presenter reads the plan, **When** they finish, **Then** they understand the narrative thread connecting all sections (why each topic follows the previous one).
2. **Given** a new presenter reads the plan, **When** they reach any demo, **Then** they have enough information to reproduce and run it independently.

---

### User Story 4 - Contributor Updates Slides in Line With the Plan (Priority: P1)

Before making any change to `slides.md`, a contributor consults the plan, updates the plan to reflect the intent of the change, and only then modifies the slide deck. The plan is always the authoritative source of truth; `slides.md` must conform to it, never the reverse.

**Why this priority**: If slides can diverge from the plan without restriction, the plan loses its value as a governance document and the session becomes inconsistent.

**Independent Test**: Can be fully tested by proposing a slide change and verifying that the workflow requires a plan update to be recorded before or alongside the slide edit.

**Acceptance Scenarios**:

1. **Given** a contributor wants to add a new section to `slides.md`, **When** they follow the documented workflow, **Then** the plan is updated first and the slide change is made only after the plan reflects the new section.
2. **Given** a contributor modifies an existing slide without updating the plan, **When** the plan and slide deck are compared by a reviewer, **Then** the discrepancy is detectable — the plan has no corresponding entry for the change. No tracking mechanism inside `slides.md` is required to detect this.
3. **Given** the plan is updated to remove a section, **When** the slide deck is reviewed, **Then** the corresponding slides are also removed so no orphan content remains.

---

### Edge Cases

- What happens when a new slide is added to `slides.md` but the plan is not updated — is the plan considered stale?
- How does the plan handle a concept first introduced in one section but only demonstrated in a later section (e.g., volumes explained in Part 1, first used in the Compose demo)? The plan section where the concept is introduced notes "Demo deferred to [later section]" and the later section’s demo entry covers it fully.
- What if a section has no demo — is that explicitly noted or simply omitted?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The plan document MUST contain a sequential outline of all presentation sections matching the order of `slides.md`.
- **FR-002**: Each outline entry MUST include a short description of the teaching goal for that section (what the audience is expected to understand after it).
- **FR-003**: The plan document MUST contain two clearly separated top-level sections: (1) a full **Outline** section and (2) a **Demos** section. The Outline section MUST be self-contained and independently readable — it is the primary planning artifact and MUST be shareable with stakeholders (e.g., a manager) before the session is finalised, without requiring them to read the demos section.
- **FR-004**: Each demo entry MUST include: the demo name, the section it belongs to, the concept it illustrates, the commands or steps to execute, and any prerequisites.
- **FR-005**: Each demo entry MUST include a fallback or recovery note for when the demo fails.
- **FR-006**: The plan document MUST state the total estimated session duration (target range: 55–70 minutes) and a per-section time allocation.
- **FR-007**: The plan document MUST be a standalone Markdown file structured in two parts: an **Outline** section (section order, teaching goals, time estimates, and "demo: yes/no" indicator per section) and a **Demos** section (full demo catalogue in session order with commands, prerequisites, and fallback notes). The Outline section MUST be readable and meaningful on its own, without requiring the Demos section.
- **FR-008**: The plan document MUST be stored in the `presentation/` directory alongside `slides.md`.
- **FR-009**: Sections that have no associated demo MUST explicitly note "No demo" so the absence is intentional and visible.
- **FR-010**: The plan document MUST be updated before any change is made to `slides.md`. The constraint is a workflow convention only — no tracking metadata, change-log annotations, or audit markers are added to `slides.md` itself. Compliance is verified by comparing the plan against the slide deck, not by any in-file mechanism.
- **FR-011**: The demos across the session MUST follow a single progressive narrative: a sample application is built up incrementally over the course of the presentation. Each demo step MUST build on the state left by the previous demo. The arc runs: pull a dependency image → run it → build the application image → wire services together with Compose → deploy the fully functional application to a local Kubernetes cluster (minikube). The application MUST be functional at the end of the Kubernetes deployment step — not just scheduled, but reachable and operating correctly. K8s concepts introduced during demos are limited to those strictly required to achieve a functional deployment. Demo placement per section is determined by practical teaching value: a concept MAY be introduced without a demo if its hands-on payoff belongs to a later section (e.g., volumes are introduced conceptually in the Docker section but first demonstrated practically within the Compose demo).
- **FR-012**: The plan document MUST describe the sample application used in the demos: a classic 3-tier web application consisting of an nginx frontend, a Python API (Flask or FastAPI), and a PostgreSQL database. The description MUST cover the purpose of each component, how they relate to each other, and why this stack was chosen as a teaching vehicle (each tier maps to a distinct Docker concept introduced during the session).

### Key Entities

- **Session Section**: A logical block of the presentation (e.g., "Docker Architecture"). Has a title, teaching goal, estimated duration, slide range reference, and zero or more associated demos. Sections without a demo explicitly state "No demo".
- **Demo**: A live, runnable exercise tied to a session section. Has a name, concept illustrated, prerequisites, step-by-step commands, a fallback note, and a reference to the application state it leaves behind (for the next demo to build on). Demo placement is at the plan author’s discretion based on practical teaching value — a concept introduced in one section may have its first demo in a later section where the hands-on payoff is greater.
- **Outline**: The primary planning artifact. An ordered list of all session sections, each with a title, teaching goal, estimated duration, slide range reference, and a "demo: yes / no" indicator. The Outline is independently shareable (e.g., for manager review) without the rest of the plan document.
- **Progressive Demo Application**: A 3-tier web application built incrementally across all demo steps: an nginx frontend, a Python API (Flask or FastAPI), and a PostgreSQL database. Its state at the end of each demo is the starting state for the next. The Docker section is the primary teaching vehicle; the Kubernetes deployment at the end is a showcase of the end-result deployment scenario.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A presenter can identify the teaching goal of any section in under 30 seconds of reading the plan.
- **SC-002**: A presenter can locate and execute any demo using only the plan document, with zero lookups into the slide deck.
- **SC-003**: A new presenter with no prior session knowledge can reconstruct the full session order and all demo steps from the plan alone.
- **SC-004**: Every demo listed in the plan runs successfully on a standard developer laptop when prerequisites are met, as defined by the Reproducibility principle in the constitution.
- **SC-005**: Running all demo steps in sequence, from first to last, produces a fully functional application deployed on a local Kubernetes cluster (minikube), reachable and operating correctly, without any manual setup beyond the stated prerequisites.
- **SC-006**: Any section or demo present in `slides.md` has a corresponding entry in the plan document. No content in `slides.md` exists without prior representation in the plan.

## Assumptions

- The presentation plan is a human-authored Markdown document, not auto-generated from `slides.md`.
- The primary audience for the plan is the presenter(s), not session attendees.
- The plan covers the full session as currently structured in `slides.md` (two parts: Docker fundamentals + Orchestration). The Kubernetes target environment for demos is a local development cluster (minikube) — no cloud provider or remote cluster is required. The session consists of 12 sections over 55–70 minutes.
- Demo commands are assumed to target macOS, Linux, or Windows with WSL2 — consistent with the Reproducibility principle in the constitution.
- The plan will be kept in sync with `slides.md` manually; automated sync tooling is out of scope for this feature.
- Session duration and time allocations are estimates; the session may run 55–70 minutes. Exact timing will be adjusted during rehearsal.
- The sample application for the progressive demo is a 3-tier web application: nginx frontend, Python API (Flask or FastAPI), and PostgreSQL. Each tier is introduced progressively as the relevant Docker concept is covered (single container → networking → volumes → Compose → K8s). The Kubernetes deployment is a showcase of the end-result scenario, not a primary teaching focus — the Docker section carries the core instructional weight.
- Not every section of the presentation requires a demo; concept-heavy sections (e.g., VM vs container comparison, architecture diagrams) may be explanation-only.

## Clarifications

### Session 2026-07-30

- Q: Should the plan-first governance rule be enforced by any tracking or annotation mechanism inside `slides.md`? → A: No. The rule is a workflow convention only. `slides.md` must not contain any change-log, tracking metadata, or audit markers. Compliance is verified by comparing the plan and the slide deck side-by-side — FR-010 and SC-006 updated accordingly.
- Q: Should the progressive demo continue into the Kubernetes section, deploying the same application to a cluster? → A: Yes. The arc extends to a local cluster (minikube). The application must be fully functional inside that deployment. The Kubernetes section is a showcase of the end-result deployment scenario — the Docker section carries the primary instructional weight.
- Q: What technology stack should the sample application use? → A: Python API (Flask or FastAPI) + PostgreSQL + nginx frontend — classic 3-tier web app. Kubernetes deployment at the end is a showcase bonus; Docker is the core instructional focus.
- Q: How should demos that span multiple non-contiguous sections be structured in the plan? → A: Presenter’s choice based on practical value. If a concept’s hands-on payoff belongs to a later section, the introduction section notes “Demo deferred to [later section]” and the demo entry lives in the later section. No forced split or spanning entry required (e.g., volumes introduced conceptually in the Docker section, first demoed in Compose).- Q: What internal structure should the plan document follow? → A: Separated. A full standalone Outline section comes first (primary planning artifact, independently shareable with stakeholders). A distinct Demos section follows as a catalogue. Demo detail is populated during planning/implementation, not in the spec phase.