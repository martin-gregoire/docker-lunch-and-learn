# Research: Presentation Plan Document

**Phase**: 0 — Outline Reconciliation & Demo Arc Design
**Date**: 2026-07-30
**Feature**: [spec.md](spec.md)

---

## 1. Reconciling the Two Source Outlines

### Inputs

| Source | Sections | Total Time | Notable gaps |
|--------|----------|------------|--------------|
| Attached outline (`Docker-lunch&learn-outline.md`) | 8 sections | ~55 min | No Docker Compose; K8s section omits ConfigMaps, Secrets, PVCs; demo is one monolithic 15-min block |
| `slides.md` (current state) | 28 slides across 13 logical sections | Unspecified | Contains more depth than a 55-min session can cover |

### Key Decisions

#### Decision 1 — Docker Compose must be added as a dedicated section

- **Rationale**: Docker Compose is the critical pedagogical bridge between "running a single container" and "Kubernetes." Without it, attendees have no context for why orchestration tooling exists. It is also the practical home for the most impactful demo checkpoint (bringing up the full 3-tier stack with one command). Omitting it creates a conceptual gap the audience will notice.
- **Alternatives considered**: Compressing Compose into the Docker Fundamentals section (10 min already full), or mentioning it only in the K8s comparison table. Both rejected — Compose deserves its own 5 min so attendees leave knowing it exists and can use it for local dev immediately.
- **Outcome**: Section 6 (Docker Compose) added to the reconciled outline. `slides.md` already has this content (slides: Why Docker Compose? · Compose YAML · Compose Commands).

#### Decision 2 — Progressive demo checkpoints woven through theory sections; K8s demo block for showcase

- **Rationale**: The spec (FR-011) requires a progressive demo narrative where each step builds on the previous state. A single 15-min monolithic demo block cannot show incremental progression — it would require the presenter to either rush through everything or skip earlier Docker concepts. Distributing brief checkpoints (1–2 min each) into sections 4, 5, and 6 lets the audience see each Docker concept demonstrated in context immediately after it's explained.
- **Alternatives considered**: Keeping the single 15-min demo block and just skipping the incremental steps. Rejected — this loses the pedagogical value of showing the app build up step by step.
- **Outcome**: 4 demo checkpoints (see Section 3 below). Sections 4, 5, 6 each have a 1–2 min checkpoint. Section 9 has the full 10-min K8s showcase demo.

#### Decision 3 — Slides.md content to consolidate or defer

The current `slides.md` has more content than the 55-min session can accommodate at a comfortable pace. The following slides are designated for consolidation or removal when `slides.md` is updated to match the plan (plan-first convention):

| Slide | Disposition | Reason |
|-------|-------------|--------|
| Full Stack Example — YAML | **Remove** | Too long; covered by demo instead |
| kubectl Cheat-Sheet (standalone slide) | **Consolidate** | Weave key commands into the Section 9 demo entry |
| Deployment Strategies (standalone slide) | **Consolidate** | Mention RollingUpdate briefly within Section 8 (K8s Core Concepts); remove Blue/Green and Canary details |
| Compose → Kubernetes Mapping | **Keep** | Highly valuable; bridges sections 6 and 7 |
| ConfigMaps & Secrets | **Keep (brief)** | Required for demo (env var injection for DB connection string) |
| Persistent Volumes / PVC | **Keep (brief)** | Required for demo (postgres data persistence) |
| Resources & Next Steps | **Keep** | Folds into Section 10 (Useful Tools & Ecosystem) |

#### Decision 4 — K8s scope limited to what the demo requires

- **Rationale**: The attached outline scopes K8s to "Pods, Deployments, Services." The demo also needs ConfigMap (env vars), Secret (DB password), and PVC (Postgres storage). These are covered briefly in Section 8, motivated by the demo need rather than as comprehensive K8s curriculum.
- Content explicitly out of scope for the session: HPA, Argo Rollouts, Flagger, Istio, Helm, network policies, StatefulSets (mention PVC as the pragmatic substitute).
- **Outcome**: K8s section covers exactly what is needed to understand and follow the Section 9 demo.

---

## 2. Reconciled Outline

> This is the authoritative section order for `presentation/PLAN.md` and governs all future changes to `slides.md`.

| # | Section Title | Teaching Goal | Time | Demo |
|---|---------------|---------------|------|------|
| 1 | The "It Works on My Machine" Problem | Audience understands why environment inconsistency is a costly, universal problem that containers solve | 4 min | No demo |
| 2 | Containers vs. Virtual Machines | Audience understands what a container is structurally, why it is lighter and faster than a VM, and when each is appropriate | 4 min | No demo |
| 3 | The Container Ecosystem | Audience understands the Linux primitives that make containers possible (namespaces, cgroups), what the CRI is, and why Docker is one of several interchangeable runtimes (Podman, containerd, CRI-O) | 6 min | No demo |
| 4 | Docker Architecture & Images | Audience understands the Daemon–CLI–Registry triangle and what an image layer is | 4 min | No demo |
| 5 | Dockerfiles & Best Practices | Audience can read and write a basic Dockerfile; understands multi-stage builds, layer caching, and non-root users | 5 min | **Demo checkpoint 1** |
| 6 | Core CLI, Networking & Volumes | Audience knows the essential `docker` commands and understands how containers communicate via custom networks and persist data via volumes | 5 min | **Demo checkpoint 2** |
| 7 | Docker Compose | Audience understands how to define a multi-container stack declaratively, build images with Compose, and iterate through the developer inner loop (code change → rebuild one service → verify) without restarting the entire stack | 5 min | **Demo checkpoint 3** |
| 8 | Why Kubernetes? & K8s Architecture | Audience understands the limitations of single-host Compose and what problem K8s solves; can describe the control-plane / worker-node split | 5 min | No demo |
| 9 | K8s Core Concepts | Audience understands Pods, Deployments, Services, ConfigMaps, Secrets, and PVCs at the level needed to follow the demo | 7 min | No demo |
| 10 | LIVE DEMO — Deploy to Cluster | Audience sees the 3-tier app deployed and running on a local K8s cluster; understands the Compose → K8s mapping | 10 min | **Demo checkpoint 4** |
| 11 | Useful Tools & Resources | Audience leaves with a curated list of ecosystem tools to explore next | 4 min | No demo |
| 12 | Q&A | Audience can ask questions and clarify adoption paths for their team | 4 min | — |
| | **Total** | | **63 min** | |

> Note: The current outline totals 63 min, within the 55–70 min session window. The remaining ~7-min buffer can be used for extended Q&A, slower demo pacing, or restoring the Deployment Strategies and kubectl Cheat-Sheet standalone slides if the presenter wants more depth.

---

## 3. Progressive Demo Arc

The demo narrative builds a single application — **`lunchdemo`** — incrementally across checkpoints 1–4.

### Application: `lunchdemo`

A minimal 3-tier web application:
- **nginx** — static frontend (serves `index.html`; proxies `/api` to the Python API)
- **Python API** (Flask) — `GET /api/items` returns a JSON list of items from PostgreSQL
- **PostgreSQL 16** — stores the `items` table

The app is intentionally simple so the audience focuses on Docker/K8s concepts rather than application logic.

### Demo Checkpoint 1 — Build the Python API image
**Section**: 5 (Dockerfiles & Best Practices)
**Concept illustrated**: Writing a Dockerfile; building an image; layer caching
**Inherited state**: Clean Docker install; nothing running
**Steps**:
1. Show `api/Dockerfile` (multi-stage: `python:3.12-slim` builder → slim runtime; non-root user)
2. `docker build -t lunchdemo-api:1.0 ./api`
3. `docker images` — observe the new image
**Resulting state**: `lunchdemo-api:1.0` image exists locally
**Fallback**: Pre-built image available as `docker pull ghcr.io/[org]/lunchdemo-api:1.0`

---

### Demo Checkpoint 2 — Run the stack with manual `docker run`
**Section**: 6 (Core CLI, Networking & Volumes)
**Concept illustrated**: Custom bridge network; named volume; container-name DNS; `docker run` flags
**Inherited state**: `lunchdemo-api:1.0` image exists
**Steps**:
1. `docker network create lunchdemo-net`
2. `docker volume create lunchdemo-pgdata`
3. `docker run -d --name db --network lunchdemo-net -v lunchdemo-pgdata:/var/lib/postgresql/data -e POSTGRES_PASSWORD=secret postgres:16-alpine`
4. `docker run -d --name api --network lunchdemo-net -e DATABASE_URL=postgresql://postgres:secret@db:5432/lunchdemo -p 8000:8000 lunchdemo-api:1.0`
5. `curl http://localhost:8000/api/items` — observe JSON response
**Resulting state**: `db` and `api` containers running; API reachable on port 8000
**Fallback**: Show `docker ps` output as static screenshot; explain expected behaviour verbally

---

### Demo Checkpoint 3 — Build, run, and iterate with Docker Compose
**Section**: 7 (Docker Compose)
**Concept illustrated**: Declarative multi-container stack; building images with Compose; `depends_on` with health checks; the typical developer inner loop (code change → rebuild → verify)
**Inherited state**: `db` and `api` containers running from checkpoint 2 (will be replaced)
**Steps**:
1. `docker compose down` — tear down the manual containers
2. Show `docker-compose.yml` (nginx + api + db services; `build: ./api` on the api service; pgdata volume; health check on db)
3. `docker compose build` — build all images defined with a `build:` key; observe layer caching on second run
4. `docker compose up -d` — start the full stack
5. `docker compose ps` — all three services healthy
6. Open `http://localhost` in browser — nginx serves the frontend, which calls the API
7. **Simulate the dev loop**: add a new pip dependency to `requirements.txt` (e.g., `python-json-logger` for structured JSON logging) and update the API to use it — a change that is impossible to apply without reinstalling packages inside the container and therefore genuinely requires a rebuild
8. `docker compose build api && docker compose up -d --no-deps api` — rebuild and replace only the changed service; database and nginx keep running
9. Refresh browser — change is live; other services were untouched
**Resulting state**: Full 3-tier stack running via Compose; API rebuilt from source; audience has seen the complete developer inner loop
**Fallback**: Show `docker compose ps` pre-recorded output; describe the rebuild step verbally with the before/after source diff on screen

---

### Demo Checkpoint 4 — Deploy to local Kubernetes cluster
**Section**: 10 (LIVE DEMO — Deploy to Cluster)
**Concept illustrated**: Compose → K8s mapping; Deployment, Service (NodePort), ConfigMap, Secret, PVC; `kubectl apply`; verifying a running deployment
**Inherited state**: 3-tier app running in Compose; minikube already started (`minikube start`)
**Steps**:
1. `docker compose down` — stop Compose stack
2. Briefly show the K8s manifests (`k8s/` directory): Deployment + Service (NodePort) for nginx and api; StatefulSet + PVC + Service (ClusterIP) for db; ConfigMap for non-sensitive config; Secret for DB password
3. `kubectl apply -f k8s/`
4. `kubectl get pods` — wait for all pods Running
5. `kubectl get services` — note NodePort for nginx
6. `minikube service nginx --url` — get the cluster URL
7. Open URL in browser — app is served from the cluster
**Resulting state**: Full 3-tier app running on minikube; reachable in browser
**Fallback**: `minikube kubectl -- get pods` pre-recorded output; show the browser screenshot

---

## 4. Slides.md Alignment Status

| `slides.md` section | Maps to reconciled section | Action needed |
|--------------------|--------------------------|---------------|
| Title slide | — | Keep as-is |
| Agenda | — | Update to match reconciled outline section titles |
| The Problem | Section 1 | Keep; minor wording update |
| VMs vs Containers | Section 2 | Keep as-is |
| *(new)* The Container Ecosystem | Section 3 | **New slide(s) needed**: Linux namespaces & cgroups (brief); CRI overview; Docker vs Podman vs containerd vs CRI-O comparison table |
| Docker Architecture | Section 4 | Keep as-is |
| Docker Images | Section 4 | Keep as-is (combine with architecture) |
| The Dockerfile + Best Practices | Section 5 | Keep; adapt examples to `lunchdemo-api` |
| Core CLI Commands | Section 6 | Keep; trim to most-used commands |
| Networking | Section 6 | Keep as-is |
| Volumes | Section 6 | Keep as-is; note "Demo deferred to Section 6" |
| Part 2 cover slide | — | Keep |
| Why Docker Compose? | Section 7 | Keep as-is |
| Docker Compose YAML | Section 7 | Replace example with `lunchdemo` Compose file; ensure `build:` key shown on the api service alongside the pre-built image services |
| Compose Commands Cheat-Sheet | Section 7 | Keep; trim |
| Why Kubernetes? | Section 8 | Keep as-is |
| Kubernetes Architecture | Section 8 | Keep as-is |
| The Pod | Section 9 | Keep; trim YAML to minimal example |
| Deployments | Section 9 | Keep; trim YAML |
| Services | Section 9 | Keep; trim table; keep Compose→K8s mapping |
| ConfigMaps & Secrets | Section 9 | Keep; trim to demo-relevant subset |
| Persistent Volumes | Section 9 | Keep; trim; add StatefulSet note |
| kubectl Cheat-Sheet | Section 10 | Consolidate into demo section; remove standalone slide |
| Deployment Strategies | Section 8 | Consolidate to 1 mention of RollingUpdate within Deployments slide; remove standalone slide |
| Full Stack Example — YAML | Remove | Replaced by live demo |
| Compose → K8s Mapping | Section 9 (intro) | Keep as first slide of demo section |
| Summary | Section 10 | Keep |
| Resources & Next Steps | Section 10 | Keep; merge into Useful Tools slide |
| Thank You / Q&A | Section 11 | Keep |
