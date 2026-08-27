---
description: "Task list for 001-presentation-plan"
---

# Tasks: Presentation Plan Document

**Input**: Design documents from `/specs/001-presentation-plan/`

**Branch**: `001-presentation-plan`
**Spec**: [spec.md](spec.md) · **Plan**: [plan.md](plan.md) · **Research**: [research.md](research.md)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no incomplete dependencies)
- **[US1–US4]**: User story this task belongs to
- All file paths are relative to repository root

---

## Phase 1: Setup

**Purpose**: Create the skeleton files and directory structure everything else builds on.

- [X] T001 Create `presentation/PLAN.md` with header (title, target duration, audience, last-updated date) and two empty top-level sections: `## Part 1 — Outline` and `## Part 2 — Demos` per `contracts/plan-format.md`
- [X] T002 [P] Create `demo/` directory structure: `demo/api/`, `demo/nginx/`, `demo/k8s/`

---

## Phase 2: Foundational — Sample Application (`lunchdemo`)

**Purpose**: Build the `lunchdemo` source files that all demo checkpoints reference. No Demos section task can be written accurately until these files exist and are verified.

**⚠️ CRITICAL**: Phases 5 and 6 cannot begin until this phase is complete.

- [X] T003 Write `demo/api/app.py` — Flask app with `GET /api/items` (returns JSON list from PostgreSQL), `GET /api/health` (returns `{"status": "ok"}`), and db connection via `DATABASE_URL` env var
- [X] T004 [P] Write `demo/api/requirements.txt` — `flask`, `psycopg2-binary`, `gunicorn`
- [X] T005 [P] Write `demo/api/Dockerfile` — multi-stage build (`python:3.12-slim` builder → slim runtime; non-root user `appuser`; `EXPOSE 8000`; `CMD ["gunicorn", ...]`) per constitution Hands-On Examples principle
- [X] T006 [P] Write `demo/nginx/nginx.conf` — serves static `index.html` on port 80; proxies `/api/` to `api:8000`; and `demo/nginx/Dockerfile` (`FROM nginx:1.27-alpine`, copies conf)
- [X] T007 Write `demo/docker-compose.yml` — three services: `nginx` (build: `./nginx`, ports `80:80`), `api` (build: `./api`, env `DATABASE_URL`, `depends_on: db: condition: service_healthy`), `db` (`postgres:16-alpine`, named volume `pgdata`, healthcheck); networks: `backend`
- [X] T008 [P] Write `demo/api/app_v2.py` and updated `demo/api/requirements_v2.txt` adding `python-json-logger` — the Demo 3 dev-loop artifact (structured JSON logging replacing plain text; verifiable without a browser)
- [X] T009 Write `demo/k8s/` manifests: `namespace.yaml`, `configmap.yaml` (non-sensitive config), `secret.yaml` (DB password), `api-deployment.yaml` + `api-service.yaml` (NodePort), `nginx-deployment.yaml` + `nginx-service.yaml` (NodePort), `db-statefulset.yaml` + `db-service.yaml` (ClusterIP) + `db-pvc.yaml` per data-model.md Demo entity
- [X] T010 [P] Write `PREREQUISITES.md` at repo root listing all required tools with minimum versions and `--version` verification commands (Docker Engine ≥ 26, Compose plugin ≥ 2, minikube ≥ 1.33, kubectl ≥ 1.30, Python 3.12)

**Checkpoint**: `lunchdemo` app is buildable and runnable — run `docker compose -f demo/docker-compose.yml up -d` and verify `curl http://localhost/api/items` returns HTTP 200.

---

## Phase 3: User Story 1 — Presenter Reviews Full Outline (Priority: P1) 🎯 MVP

**Goal**: A presenter can open `presentation/PLAN.md`, read the Outline section, and reconstruct the full session order, teaching goals, and demo touchpoints — without opening `slides.md`.

**Independent Test**: Open `presentation/PLAN.md` and confirm a reader with no prior knowledge of the session can identify every section in order, its teaching goal, its duration, and whether it has a demo — in under 30 seconds per section.

- [X] T011 [US1] Write Application Overview section in `presentation/PLAN.md` — app name (`lunchdemo`), 3-sentence description, Components table (nginx · Python API · PostgreSQL with image/source, role, Docker concept each introduces), source location (`demo/`), and teaching rationale per FR-012
- [X] T012 [US1] Write all 12 Section entries in Part 1 — Outline of `presentation/PLAN.md`, each with: title, teaching goal (one sentence starting "Audience…"), estimated duration, slides reference, and explicit demo indicator (`No demo` / `Demo checkpoint N — label` / `Demo deferred to §N — reason`) per FR-001, FR-002, FR-006, FR-007, FR-009 and the reconciled outline in `research.md`
- [X] T013 [US1] Add Outline summary table at the end of Part 1 in `presentation/PLAN.md` — one row per section showing number, title, duration, demo indicator; final row shows total duration (verify falls within 55–70 min per data-model.md invariant)

**Checkpoint**: US1 independently testable — `presentation/PLAN.md` Part 1 passes quickstart.md Validations 1 and 2 (outline completeness + demo indicator coverage).

---

## Phase 4: User Story 4 — Contributor Updates Slides in Line With the Plan (Priority: P1)

**Goal**: Every section in the reconciled outline has a corresponding slide; no orphan slide headings exist; the plan-first convention is documented and discoverable.

**Independent Test**: Run quickstart.md Validation 8 — zero orphan slide headings in `slides.md`; `PLAN.md` `Last Updated` date ≥ last commit date of `slides.md`.

- [X] T014 [US4] Add plan-first convention note to the preamble of `presentation/PLAN.md` (above Part 1): one short paragraph stating that `slides.md` must never be modified without first updating this document, and how to detect drift (compare section headings) per FR-010
- [X] T015 [US4] Update `presentation/slides.md` Agenda slide section titles to match the 12 reconciled section titles from T012; update Part 1 and Part 2 bullet lists per `research.md` Section 4 (Slides.md Alignment Status)
- [X] T016 [P] [US4] Fix `presentation/slides.md` frontmatter: change `colorSchema: dark` to `colorSchema: light` to comply with constitution Presentation Standards (light theme with Docker/K8s brand palette)
- [X] T017 [US4] Add new Section 3 slides to `presentation/slides.md` (after VMs vs Containers, before Docker Architecture): (1) Linux namespaces & cgroups diagram slide explaining the OS primitives that make isolation possible; (2) Container Runtime Interface (CRI) slide explaining what CRI standardises; (3) Docker alternatives comparison table slide (Docker · Podman · containerd · CRI-O: key differentiator per runtime) per `research.md` Section 4 new slide requirement

**Checkpoint**: US4 independently testable — zero orphan headings; Agenda matches outline; light theme applied; new ecosystem slides present.

---

## Phase 5: User Story 2 — Presenter Locates Demo Instructions During Session (Priority: P2)

**Goal**: A presenter can find and execute any demo checkpoint from `presentation/PLAN.md` alone, without consulting `slides.md` or any other file.

**Independent Test**: Simulate a live session — using only `presentation/PLAN.md` and a terminal, execute all 4 demo checkpoints in sequence per quickstart.md Validations 4–7.

- [X] T018 [US2] Write Part 2 — Demos section header in `presentation/PLAN.md`: one-paragraph intro explaining the progressive narrative arc and the `lunchdemo` application; note that each checkpoint's `Inherited state` describes what the previous checkpoint left behind
- [X] T019 [US2] Write Demo Checkpoint 1 in `presentation/PLAN.md` — name, section ref (§5), concept (Dockerfile · multi-stage build · layer caching), inherited state (clean install), prerequisites (Docker Engine ≥ 26), numbered steps with fenced `bash` commands and expected output, fallback (pre-pulled image), resulting state (`lunchdemo-api:1.0` image exists) per FR-004, FR-005 and `contracts/plan-format.md`
- [X] T020 [P] [US2] Write Demo Checkpoint 2 in `presentation/PLAN.md` — name, section ref (§6), concept (custom bridge network · named volume · container-name DNS), inherited state (image from checkpoint 1), prerequisites, numbered steps (`docker network create` · `docker volume create` · two `docker run` commands · `curl` verification), fallback, resulting state (`db` + `api` containers running on port 8000) per FR-004, FR-005
- [X] T021 [US2] Write Demo Checkpoint 3 in `presentation/PLAN.md` — name, section ref (§7), concept (declarative stack · `docker compose build` · dev inner loop), inherited state (containers from checkpoint 2), prerequisites, numbered steps including `docker compose down` · show `docker-compose.yml` with `build:` key · `docker compose build` · `docker compose up -d` · open browser · add `python-json-logger` to `requirements_v2.txt` + update `app_v2.py` · `docker compose build api && docker compose up -d --no-deps api` · verify JSON logs), fallback, resulting state (full 3-tier stack running via Compose) per FR-004, FR-005
- [X] T022 [US2] Write Demo Checkpoint 4 in `presentation/PLAN.md` — name, section ref (§10), concept (Compose→K8s mapping · Deployment · Service · ConfigMap · Secret · PVC · `kubectl apply`), inherited state (Compose stack running; minikube pre-started), prerequisites (minikube ≥ 1.33 · kubectl ≥ 1.30), numbered steps (`docker compose down` · `eval $(minikube docker-env)` · rebuild image · `kubectl apply -f demo/k8s/` · `kubectl wait` · `kubectl get pods/services` · `minikube service nginx --url` · open in browser), fallback (pre-recorded `kubectl get pods` output + browser screenshot), resulting state (app running on minikube; reachable in browser) per FR-004, FR-005

**Checkpoint**: US2 independently testable — run quickstart.md Validations 3 (demo chain integrity) and 4–7 (end-to-end demo execution).

---

## Phase 6: User Story 3 — New Presenter Onboards to the Session (Priority: P3)

**Goal**: A new presenter can pick up `presentation/PLAN.md` and deliver the session without any prior briefing.

**Independent Test**: A new presenter reads only `presentation/PLAN.md` and can explain why each section follows the previous one, and can run every demo without asking questions.

- [X] T023 [US3] Add a one-sentence narrative connector to each Section entry in Part 1 of `presentation/PLAN.md` — a "Why this follows the previous section" note that makes the session's logical progression explicit for a new presenter (e.g., "Having seen what containers are structurally, we now look at the ecosystem of runtimes that implement them before focusing on Docker specifically")
- [X] T024 [P] [US3] Verify demo chain integrity in `presentation/PLAN.md` per quickstart.md Validation 3: confirm `Resulting state` of checkpoint N exactly matches `Inherited state` of checkpoint N+1; update wording if any mismatch found

**Checkpoint**: US3 independently testable — a reviewer unfamiliar with the session reads `presentation/PLAN.md` and can answer: "Why does section 3 come before section 4?" and "What exact state does Demo 2 leave behind for Demo 3?" without consulting any other file.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: End-to-end validation; slides.md content alignment; final format check.

- [X] T025 Run quickstart.md Validations 4–7 end-to-end (execute all 4 demo checkpoints sequentially on a clean machine); fix any command errors found in `presentation/PLAN.md` or demo source files
- [X] T026 [P] Run quickstart.md Validation 8 (plan-first governance): count `# …` headings in `slides.md` that have no corresponding Section entry in `presentation/PLAN.md`; resolve any orphans
- [X] T027 [P] Run quickstart.md Validations 1–2 (outline completeness + demo indicator coverage): confirm 12 sections, 4 checkpoint references, 8 "No demo" entries, 0 blank `**Demo**:` fields; update `presentation/PLAN.md` `Last Updated` date

---

## Dependencies

```
T001 ──► T011 ──► T012 ──► T013
     └──► T014         └──► T023 ──► T024
T002 ──► T003 ──► T007 ──► T021
     ├──► T004 ─┘
     ├──► T005 ──► T007 ──► T009 ──► T022
     ├──► T006 ─┘
     └──► T008 (logger variant, feeds T021)

T012 ──► T015 ──► T017
T012 + T018 ──► T019, T020, T021, T022

T019 + T020 + T021 + T022 ──► T024 ──► T025
T015 + T017 ──► T026
T012 + T013 + T018-T022 ──► T027

T028 ──► T029, T030, T031, T032, T033, T034, T035, T036, T037

T012 + T015 + T017 + T028-T037 ──► T038, T039, T040, T041, T042, T043, T044, T045, T046
T038 + T039 + T040 + T041 + T042 + T043 + T044 + T045 + T046 ──► T047
```

## Parallel Execution Opportunities

| Story | Parallelizable group | Tasks |
|-------|---------------------|-------|
| Foundational | Sample app files (after T002) | T003, T004, T005, T006, T008, T010 |
| US1 | After T012 | T013 alongside T014 |
| US4 | After T015 | T016 alongside T017 |
| US2 | After T018 | T019 alongside T020; T021 and T022 after T007/T009 |
| US3 | After T022 | T023 alongside T024 |
| Polish | After T022 | T026 alongside T027; T025 last |
| Slide docs | After T028 | T029–T037 all in parallel |
| Slide authoring | After T015, T017, T037 | T038–T046 all in parallel |

## Phase 8: Slide-Building Documentation

**Purpose**: Enrich each Section entry in `presentation/PLAN.md` with three new fields so slides can be built directly from the plan:
- `**Slide content**` — 3–5 bullet talking points the slide must cover (suggestions; final content is the implementer’s responsibility)
- `**References**` — links to authoritative official docs/specs for accuracy verification
- `**Media**` — entries prefixed `[use]` (link to an existing official diagram/image) or `[create]` (description of a custom visual to be authored for the slide)

**Prerequisite**: T028 must complete before T029–T037 (format contract defines the field structure).

- [X] T028 Update `specs/001-presentation-plan/contracts/plan-format.md` to add `**Slide content**`, `**References**`, and `**Media**` as required fields in the Section entry format; document the `[use]` / `[create]` distinction for the Media field
- [X] T029 [P] Enrich §1 (The Problem) and §2 (Containers vs VMs) in `presentation/PLAN.md` with Slide content, References, and Media fields
- [X] T030 [P] Enrich §3 (The Container Ecosystem) in `presentation/PLAN.md` — includes `[create]` entries for a Linux namespaces/cgroups diagram and a CRI abstraction layer diagram
- [X] T031 [P] Enrich §4 (Docker Architecture & Images) in `presentation/PLAN.md` — includes `[use]` entry for the official Docker architecture diagram
- [X] T032 [P] Enrich §5 (Dockerfiles & Best Practices) in `presentation/PLAN.md` — includes `[create]` entry for a multi-stage build layer diagram
- [X] T033 [P] Enrich §6 (Core CLI, Networking & Volumes) in `presentation/PLAN.md` — includes `[create]` entry for a custom bridge network diagram showing container-name DNS
- [X] T034 [P] Enrich §7 (Docker Compose) in `presentation/PLAN.md` — includes `[create]` entry for a before/after diagram (5 `docker run` commands → single `docker compose up`)
- [X] T035 [P] Enrich §8 (Why Kubernetes?) and §9 (K8s Core Concepts) in `presentation/PLAN.md` — includes `[use]` entry for the official K8s cluster architecture diagram
- [X] T036 [P] Enrich §10 (LIVE DEMO: Deploy to Cluster) in `presentation/PLAN.md` — includes `[use]` for the Compose→K8s mapping table already in `slides.md` and `[create]` for a deployment flow diagram
- [X] T037 [P] Enrich §11 (Useful Tools & Resources) in `presentation/PLAN.md` — curated tool list with one-line descriptions and homepage links; no media required

> §12 (Q&A) is explicitly excluded — no Slide content, References, or Media fields apply to an open discussion.

---

## Phase 9: Slide Authoring

**Purpose**: Write the actual slide bodies in `presentation/slides.md` for every section, using the `**Slide content**`, `**References**`, and `**Media**` fields in `presentation/PLAN.md` as the spec. Create all `[create]` visuals. Verify `[use]` media is correctly embedded.

**Prerequisites**: T015 (Agenda updated), T016 (light theme), T017 (§3 skeleton slides), T028–T037 (PLAN.md fully enriched).

- [X] T038 [P] Author §1 (The Problem) and §2 (Containers vs VMs) slide bodies in `presentation/slides.md` per PLAN.md §1–§2 Slide content; create split-panel “it works on my machine” visual and side-by-side VM vs container stack diagram per Media fields
- [X] T039 [P] Author §3 (Container Ecosystem) slide bodies in `presentation/slides.md` — namespaces/cgroups, CRI, and runtime alternatives table per PLAN.md §3 Slide content; create namespaces/cgroups diagram and CRI abstraction layer diagram per Media fields
- [X] T040 [P] Author §4 (Docker Architecture & Images) slide bodies in `presentation/slides.md` per PLAN.md §4 Slide content — add image tags, `:latest` anti-pattern, `docker push` workflow; embed official Docker architecture diagram per Media [use] field
- [X] T041 [P] Author §5 (Dockerfiles & Best Practices) slide bodies in `presentation/slides.md` per PLAN.md §5 Slide content — show `demo/api/Dockerfile` as the live example; add `.dockerignore` slide; create multi-stage build layer diagram per Media field
- [X] T042 [P] Author §6 (Core CLI, Networking & Volumes) slide bodies in `presentation/slides.md` per PLAN.md §6 Slide content — trim CLI cheat-sheet to daily-workflow commands; create bridge network diagram showing container-name DNS per Media field
- [X] T043 [P] Author §7 (Docker Compose) slide bodies in `presentation/slides.md` per PLAN.md §7 Slide content — replace placeholder YAML with `demo/docker-compose.yml` excerpt; add `.env` file concept slide; create before/after `docker run` → `docker compose up` diagram per Media field
- [X] T044 [P] Author §8 (Why Kubernetes?) and §9 (K8s Core Concepts) slide bodies in `presentation/slides.md` per PLAN.md §8–§9 Slide content — add Namespace slide; trim YAML examples to demo-minimal; embed official K8s cluster architecture diagram per Media [use] fields
- [X] T045 [P] Author §10 (LIVE DEMO) slide bodies in `presentation/slides.md` per PLAN.md §10 Slide content — verify Compose→K8s mapping table slide is present and accurate; create `kubectl apply` deployment flow diagram per Media field
- [X] T046 [P] Author §11 (Useful Tools & Resources) and §12 (Q&A) slide bodies in `presentation/slides.md` per PLAN.md §11 Slide content — add Portainer, k9s, kind, k3d with one-liners; create tool cards grid per Media field; verify Thank You/Q&A slide is present
- [X] T047 Final slide validation — run quickstart.md Validations 1 and 2 (all 12 sections covered, no orphan headings, all `**Demo**:` fields present); confirm section order matches PLAN.md Outline Summary; update `presentation/PLAN.md` `Last Updated` date

**Checkpoint**: Full slide deck matches the plan — every section has slides, every demo has a checkpoint reference, and no slide heading is orphaned.

---

## Phase 10: Convergence

- [X] T048 Add a one-sentence "Why this follows the previous section" narrative connector to each of the 12 Section entries in `presentation/PLAN.md` Part 1, making the session's logical progression explicit for a new presenter per US3/AC1 (missing)
- [X] T049 Reconcile the Section 3 duration discrepancy in `presentation/PLAN.md`: the section entry says `**Duration**: 8 min` but the Outline Summary table shows `6 min`; update one value so both are consistent per FR-006 (partial)
- [X] T050 Update the `**Last Updated**` date in `presentation/PLAN.md` header to today's date (2026-08-19), reflecting completion of all Phase 9 slide-authoring tasks per FR-010 and T027 (partial)

---

## Implementation Strategy

**MVP** (minimum to deliver US1 value): T001 → T011 → T012 → T013. This produces a shareable Outline section suitable for manager review before any demo work begins.

**Full delivery order**: Phase 1 → Phase 2 (parallelise T003–T010) → Phase 3 → Phase 4 → Phase 5 (parallelise T019/T020) → Phase 6 → Phase 7 → Phase 8 (T028 first, then T029–T037 in parallel) → Phase 9 (T038–T046 in parallel, then T047).
