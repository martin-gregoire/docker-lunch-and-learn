# Implementation Plan: Presentation Plan Document

**Branch**: `001-presentation-plan` | **Date**: 2026-07-30 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-presentation-plan/spec.md`

## Summary

Create `presentation/PLAN.md`: a two-part Markdown document containing (1) a standalone **Outline** section — the primary planning artifact, independently shareable with stakeholders — and (2) a **Demos** section cataloguing all progressive demo checkpoints. The document governs `slides.md`; no slide change is permitted without a prior plan update (convention-only, no tracking mechanism in the slides file).

The progressive demo builds a 3-tier web application (nginx frontend · Python API · PostgreSQL) incrementally through the session, ending with a functional deployment on a local Kubernetes cluster (minikube). Docker is the primary teaching focus; the K8s deployment is a showcase of the end-result scenario.

## Technical Context

**Language/Version**: Markdown (human-authored document; no programming language)

**Primary Dependencies**: None

**Storage**: `presentation/PLAN.md` (version-controlled alongside `slides.md`)

**Testing**: Manual validation — cross-reference Outline against `slides.md`; execute demo steps end-to-end

**Target Platform**: Any Markdown viewer (GitHub, VS Code preview, local browser)

**Project Type**: Documentation artifact

**Performance Goals**: N/A

**Constraints**: Outline section must be independently readable without the Demos section; demo commands must run on macOS / Linux / Windows WSL2; all demo prerequisites must be explicitly listed

**Scale/Scope**: 55–70 minute session; 12 reconciled sections; 4 progressive demo checkpoints

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Pre-Design | Post-Design | Notes |
|-----------|-----------|-------------|-------|
| I. Technical Accuracy | ✅ PASS | ✅ PASS | All commands and concepts verified against official Docker / K8s docs |
| II. Progressive Disclosure | ✅ PASS | ✅ PASS | Outline orders concepts in dependency order: containers → images → CLI → networking → Compose → K8s |
| III. Hands-On Examples | ✅ PASS | ✅ PASS | Every demo checkpoint includes runnable CLI commands |
| IV. Reproducibility | ✅ PASS | ✅ PASS | Demo commands target macOS/Linux/WSL2; prerequisites listed per demo |
| V. Simplicity | ✅ PASS | ✅ PASS | Each section conveys one primary concept; demo entries scoped to one build step |

No violations. No Complexity Tracking required.

## Project Structure

### Documentation (this feature)

```text
specs/001-presentation-plan/
├── plan.md              # This file
├── research.md          # Phase 0: reconciled outline + demo arc decisions
├── data-model.md        # Phase 1: structure of PLAN.md entities
├── quickstart.md        # Phase 1: validation guide
└── contracts/
    └── plan-format.md       # Phase 1: Markdown template / schema for PLAN.md
```

### Source Code (repository root)

```text
presentation/
├── slides.md            # Existing; governed by PLAN.md (plan-first convention)
└── PLAN.md              # New artifact — deliverable of this feature
```

**Structure Decision**: Single new file `presentation/PLAN.md`. No source code changes. The only new directory is `specs/001-presentation-plan/contracts/` (spec artifact only).
