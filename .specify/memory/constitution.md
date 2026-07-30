<!--
SYNC IMPACT REPORT
Version change: (unversioned) → 1.0.0 (2026-07-30, initial fill)
Version change: 1.0.0 → 1.0.1 (2026-07-30, theme standard updated to light/Docker-aligned palette)
Modified standards: Presentation Standards — Theme line updated from seriph dark to light (black-on-white, Docker blue accents)
Added sections: none
Removed sections: none
TODO placeholders: none
-->

# Docker Lunch & Learn Constitution

## Core Principles

### I. Technical Accuracy (NON-NEGOTIABLE)

All technical claims, commands, and architectural diagrams MUST be verified against the
official Docker and Kubernetes documentation before inclusion. Outdated or unverified
content MUST NOT be presented as current best practice.

**Rationale**: Attendees leave with mental models they apply in production; errors here
propagate into real systems.

### II. Progressive Disclosure

Concepts MUST be introduced in dependency order — foundational ideas (containers, images,
networking) before advanced topics (Compose, Kubernetes, deployment strategies). No slide
MAY assume knowledge that has not been explicitly covered earlier in the deck.

**Rationale**: Lunch-and-learn audiences have mixed experience levels; order matters for
comprehension and retention.

### III. Hands-On Examples

Every concept MUST be paired with at least one working CLI command or code snippet that
an attendee can run verbatim. Abstract diagrams alone are insufficient — they MUST always
accompany a concrete example.

**Rationale**: Practical examples anchor theoretical knowledge and enable immediate
experimentation after the session.

### IV. Reproducibility

All demos and code samples MUST run on a standard developer laptop (macOS, Linux, or
Windows with WSL2) using only documented prerequisites. Environment assumptions MUST be
stated explicitly on the relevant slide or in the README.

**Rationale**: Hands-on value is zero if attendees cannot reproduce the demo on their own
machine.

### V. Simplicity

Each slide MUST convey at most one primary concept. Slides MUST NOT exceed 7 bullet
points or equivalent information density. Prefer diagrams and code over prose.

**Rationale**: Cognitive overload during a lunch session causes disengagement; concise
slides improve retention and leave time for discussion.

## Presentation Standards

- **Tool**: Slidev (`presentation/slides.md`) is the single source of truth for all slide
  content. No external presentation files (Keynote, PowerPoint, Google Slides) are
  maintained in parallel.
- **Theme**: Slides MUST use a light colour scheme (white or off-white background, dark
  text) with accent colours drawn from the Docker and Kubernetes brand palette
  (Docker blue `#2496ED`, Kubernetes blue `#326CE5`). Dark themes MUST NOT be used.
- **Code highlighting**: Shiki MUST be used for all code blocks.
- **Transitions**: Slide transitions MUST remain uniform (`slide-left`) unless a specific
  narrative moment justifies an exception.

## Demo Requirements

- All demo commands MUST be tested end-to-end before a session delivery.
- Required tooling versions (Docker Engine, kubectl, etc.) MUST be listed in the
  repository README or a dedicated `PREREQUISITES.md`.
- Demos MUST fail gracefully with a clear error message when prerequisites are absent
  rather than producing silent or misleading output.

## Governance

This constitution supersedes informal conventions. Amendments require:

1. A clear statement of the proposed change and its rationale.
2. A version bump following semantic versioning:
   - **MAJOR**: Removal or redefinition of a principle.
   - **MINOR**: New principle or section added.
   - **PATCH**: Clarifications, wording fixes, non-semantic refinements.
3. An update to the `Last Amended` date on the version line below.

All spec, plan, and task artifacts MUST be reviewed for consistency with this constitution
before acceptance.

**Version**: 1.0.1 | **Ratified**: 2026-07-30 | **Last Amended**: 2026-07-30
