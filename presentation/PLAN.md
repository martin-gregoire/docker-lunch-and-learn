# Docker & Containerization — Lunch and Learn: Presentation Plan

**Target Duration**: 55–70 minutes
**Audience**: Software Developers & Quality Engineers
**Last Updated**: 2026-08-26

---

> **Plan-first convention**: `slides.md` must never be modified without first updating this document.
> Any section or demo present in `slides.md` must have a corresponding entry here. To detect drift,
> compare the `# …` headings in `slides.md` against the Section entries below.

---

## Application Overview

`lunchdemo` is a minimal 3-tier web application used across all demo checkpoints. An nginx frontend
serves a static page and proxies API calls to a Python (Flask) API, which reads from a PostgreSQL
database. The app is intentionally simple so the audience focuses on Docker and Kubernetes concepts
rather than application logic.

### Components

| Component | Image / Source | Role | Docker concept introduced |
|-----------|---------------|------|--------------------------|
| nginx frontend | `nginx:1.27-alpine` / `demo/nginx/Dockerfile` | Serves `index.html`; proxies `/api/` to the Python API | Pulling and running a pre-built image; multi-container networking |
| Python API | `demo/api/Dockerfile` | `GET /api/items` — returns JSON list from PostgreSQL; `GET /api/health` | Building a custom image; multi-stage Dockerfile; non-root user |
| PostgreSQL | `postgres:16-alpine` | Stores the `items` table | Named volumes for persistent storage; container-name DNS |

**Source**: `demo/`

**Why this app?** Each tier maps directly to a Docker concept introduced in the same session
section — pulling an image, building an image, and using volumes — so the demo narrative
reinforces the theory immediately after it is explained.

---

## Part 1 — Outline

> This section is the primary planning artifact. It can be shared independently with
> stakeholders without requiring them to read the Demos section.

---

### Section 1 — The "It Works on My Machine" Problem

**Teaching goal**: Audience understands why environment inconsistency is a costly, universal
problem in software delivery, and why a portable packaging solution like containers is the
right answer.
**Narrative**: Opening section — establishes the environment-consistency problem that every subsequent concept addresses.
**Duration**: 4 min
**Slides**: The Problem
**Demo**: No demo

**Slide content**:
- "Same code, different environments → unexpected failures" — the core definition of the environment problem
- The hidden cost: debugging environment-only bugs wastes engineering time and blocks releases
- Applications are implicitly coupled to the OS, libraries, and config on which they were tested
- Containers: package the app *and* its entire runtime environment → runs identically everywhere

**References**:
- [Docker overview](https://docs.docker.com/get-started/overview/) — explains the environment problem and how containers solve it

**Media**:
- [create] Split-panel diagram: "dev laptop" (library v1.2, Node 16) on the left; "CI server" (library v2.0, Node 18) on the right; broken arrow between them labelled "it works on my machine"

---

### Section 2 — Containers vs. Virtual Machines

**Teaching goal**: Audience understands what a container is structurally — shared kernel,
isolated process namespace — why it is lighter and faster than a VM, and when each
approach is appropriate.
**Narrative**: Having named the problem, we examine the solution structurally — what a container actually is under the hood, contrasted with the VM approach most developers already know.
**Duration**: 4 min
**Slides**: VMs vs Containers
**Demo**: No demo

**Slide content**:
- **VM stack**: hypervisor virtualises hardware → each VM runs a full Guest OS kernel → app runs on top
- **Container stack**: shares the host OS kernel → process isolation via namespaces + cgroups → no full OS copy
- Containers start in seconds and use tens of MB vs hundreds for VMs; VMs offer stronger kernel-level isolation
- When to use VMs: untrusted multi-tenant workloads or different OS kernels; containers: microservices, CI/CD

**References**:
- [Containers overview](https://docs.docker.com/get-started/#what-is-a-container) — Docker's side-by-side VM vs container comparison

**Media**:
- [create] Side-by-side stack diagram: left column shows VM stack (hypervisor → Guest OS → App per VM); right column shows container stack (host OS → runtime → containers sharing the kernel)

---

### Section 3 — The Container Ecosystem

**Teaching goal**: Audience understands the Linux primitives (namespaces, cgroups) that make
container isolation possible, how open standards and licensing shaped the ecosystem, what the
Container Runtime Interface (CRI) standardises, and why Docker is one of several interchangeable
runtimes alongside Podman, containerd, and CRI-O.
**Narrative**: Knowing what a container is structurally, we widen the lens to the ecosystem around it — open standards and runtimes — so the audience understands Docker as one interchangeable option, not the only one.
**Duration**: 8 min
**Slides**: Linux namespaces & cgroups · Open Standards & Licensing · CRI overview · Docker alternatives table
**Demo**: No demo

**Slide content**:
- **Namespaces**: 6 types (PID, net, mnt, uts, ipc, user) — each gives a process tree its own isolated view of a resource
- **cgroups**: enforce per-container CPU, memory, and I/O limits — prevent one container from starving others
- **Open Standards & Licensing**:
  - **OCI** (Open Container Initiative, 2015): Docker + others founded it to standardise image format and runtime spec — any OCI-compliant image runs on any compliant runtime
  - **Moby** (2017): Docker open-sourced its engine under Apache 2.0; `dockerd`/`containerd`/`runc` are now community-governed
  - **CNCF** (Cloud Native Computing Foundation): neutral home for containerd, Kubernetes, and the broader cloud-native ecosystem
  - Net result: runtimes are interchangeable — vendor lock-in is eliminated at the image and runtime layer
- **CRI** (Container Runtime Interface): Kubernetes' plug-in API to the runtime — kubelet speaks CRI; runtime executes pods
- Runtime options: Docker (daemon + UX on top of containerd), Podman (daemonless), containerd, CRI-O (bare CRI runtimes)
- **Docker Desktop licensing**: not free for commercial use (companies with >250 employees or >$10M revenue require a paid plan) — this is the primary driver behind adoption of Podman Desktop and other free alternatives

**References**:
- [Linux namespaces (man7)](https://man7.org/linux/man-pages/man7/namespaces.7.html) — authoritative reference for namespace types and isolation semantics
- [OCI Runtime Specification](https://github.com/opencontainers/runtime-spec) — defines what a compliant container runtime must implement
- [Kubernetes CRI](https://kubernetes.io/docs/concepts/architecture/cri/) — how the kubelet communicates with container runtimes

**Media**:
- [create] Linux kernel → namespaces + cgroups diagram: container process sees isolated PIDs, network, and filesystem; cgroups box shows CPU/memory limits
- [create] CRI abstraction layer diagram: Kubernetes kubelet → CRI interface → runtime options (containerd · CRI-O · Podman)

---

### Section 4 — Docker Architecture & Images

**Teaching goal**: Audience understands the Daemon–CLI–Registry triangle, how the Docker
daemon manages images and containers, and what a layered image filesystem is.
**Narrative**: With the ecosystem framed, we zoom into Docker specifically — how its daemon, CLI, and registry collaborate, and how an image is composed of immutable, cacheable layers.
**Duration**: 4 min
**Slides**: Docker Architecture · Docker Images
**Demo**: No demo

**Slide content**:
- **Daemon** (`dockerd`): background service; manages images, containers, networks, volumes via REST API on Unix socket
- **CLI** (`docker`): thin client that sends API calls to the daemon — every `docker` command is a REST request
- **Registry**: stores and distributes image layers; `docker pull` fetches, `docker push` uploads; Docker Hub is the default
- **Image tags**: `image:tag` format (e.g., `nginx:1.27-alpine`, `lunchdemo-api:1.0`); `:latest` is the implicit default but an anti-pattern in production — use semantic versions (`:1.0.3`) or Git SHAs; `docker tag` aliases a local image before pushing
- **Image layers**: each `RUN`/`COPY`/`ADD` instruction creates an immutable, cacheable read-only layer; layers are shared

**References**:
- [Docker architecture](https://docs.docker.com/get-started/overview/#docker-architecture) — official overview of daemon, client, and registry triangle
- [docker tag reference](https://docs.docker.com/reference/cli/docker/image/tag/) — syntax for tagging and aliasing images before pushing to a registry
- [Storage drivers](https://docs.docker.com/engine/storage/drivers/) — how overlay2 implements the layer filesystem

**Media**:
- [use] [Docker architecture diagram](https://docs.docker.com/get-started/images/docker-architecture.webp) — official diagram showing the client → daemon → registry triangle

---

### Section 5 — Dockerfiles & Best Practices

**Teaching goal**: Audience can read and write a basic Dockerfile; understands multi-stage
builds, layer caching, and why containers should run as a non-root user.
**Narrative**: Knowing what an image is, the audience now learns to produce one from source code — the Dockerfile is the build recipe, and multi-stage builds keep the result small and secure.
**Duration**: 5 min
**Slides**: The Dockerfile · Dockerfile Best Practices
**Demo**: No demo

**Slide content**:
- Core instructions: `FROM` (base image), `WORKDIR`, `COPY`, `RUN` (install/build), `EXPOSE`, `CMD`/`ENTRYPOINT`
- **Layer caching**: order instructions from least- to most-frequently changed — `COPY requirements.txt` before `COPY .`
- **Multi-stage builds**: compile in one `AS builder` stage; `COPY --from=builder` only the artefact into a slim runtime image
- **Non-root user**: `RUN useradd -r -u 1001 appuser && USER appuser` — limits blast radius of a container compromise
- **`.dockerignore`**: like `.gitignore` for Docker builds — prevents `COPY .` from including `.env`, `node_modules`, `.git`, and build artefacts in the image

**References**:
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/) — complete instruction syntax and semantics
- [Best practices for writing Dockerfiles](https://docs.docker.com/build/building/best-practices/) — caching, multi-stage, image size, security
- [.dockerignore file](https://docs.docker.com/reference/dockerfile/#dockerignore-file) — syntax and patterns for excluding files from the build context

**Media**:
- [create] Multi-stage build diagram: "builder" stage (python:3.12-slim + full toolchain → installs dependencies) → arrow labelled "COPY --from=builder" → "runtime" stage (slim image with only /app); discarded layers shown as greyed out

---

### Section 6 — Core CLI, Networking & Volumes

**Teaching goal**: Audience knows the essential `docker` commands for the daily workflow,
understands how containers on a custom bridge network reach each other by name, and how
named volumes provide persistent storage that survives container removal.
**Narrative**: The image now exists; this section covers running it and wiring containers together — the CLI commands and networking primitives used in every subsequent demo step.
**Duration**: 5 min
**Slides**: Core CLI Commands · Networking · Volumes
**Demo**: No demo

**Slide content**:
- Core daily workflow: `docker run -d --name`, `docker ps`, `docker logs -f`, `docker exec -it … sh`, `docker stop`, `docker rm`
- **Custom bridge network**: `docker network create lunchdemo-net`; containers on the same network resolve each other by container name
- **Named volume**: `docker volume create pgdata`; survives `docker rm`; mounted with `-v pgdata:/var/lib/postgresql/data`
- Bind mount = maps a host directory (dev hot-reload); named volume = Docker-managed persistent storage (demos, production)

**References**:
- [docker run reference](https://docs.docker.com/reference/cli/docker/container/run/) — complete flag reference for the most common command
- [Networking overview](https://docs.docker.com/engine/network/) — bridge, host, and overlay network drivers
- [Use volumes](https://docs.docker.com/engine/storage/volumes/) — volumes vs bind mounts, lifecycle management

**Media**:
- [create] Bridge network diagram: host machine → `lunchdemo-net` bridge network → `db` container (port 5432, reached as `db:5432`) and `api` container (port 8000, reached as `api:8000`); host exposes `api:8000` → `localhost:8000`

---

### Section 7 — Docker Compose

**Teaching goal**: Audience understands how to define a multi-container stack declaratively
with a single YAML file, build service images with Compose, and iterate through the
developer inner loop (add a dependency → rebuild one service → verify) without
restarting the entire stack.
**Narrative**: Running three containers manually via `docker run` is repetitive and fragile; Compose replaces that with a single declarative YAML file and one command — the natural evolution of everything covered so far.
**Duration**: 5 min
**Slides**: Why Docker Compose? · Docker Compose YAML · Compose Commands Cheat-Sheet
**Demo**: No demo

**Slide content**:
- **Compose YAML**: `services:` with `build:` or `image:`, `ports:`, `environment:`, `depends_on:` + `condition: service_healthy`
- `docker compose up -d` starts the full stack; `docker compose down` tears it all down — one command replaces many `docker run` invocations
- `docker compose build` rebuilds all services with a `build:` key and still leverages layer caching
- **Dev inner loop**: `docker compose build api && docker compose up -d --no-deps api` — rebuild one service without restarting the whole stack
- **`.env` file**: Compose reads `.env` in the project root and substitutes `${VAR}` references in the YAML — keeps secrets and per-environment values out of `docker-compose.yml`

**References**:
- [Docker Compose overview](https://docs.docker.com/compose/) — concepts, use cases, and getting started
- [Compose file reference](https://docs.docker.com/reference/compose-file/) — every key documented
- [Environment variables in Compose](https://docs.docker.com/compose/how-tos/environment-variables/) — `.env` file, variable substitution, and precedence rules

**Media**:
- [create] Before/after diagram: left side shows 5 `docker run` commands with all flags spelled out; right side shows a single `docker compose up`; arrow between them labelled "same result, one command"

---

### Section 8 — Why Kubernetes? & K8s Architecture

**Teaching goal**: Audience understands the limitations of single-host Compose at production
scale and what problem Kubernetes solves; can describe the control-plane / worker-node split
at a conceptual level.
**Narrative**: Compose handles one host reliably in development, but production demands failover, auto-scaling, and rolling updates across multiple nodes — that gap is the motivation for Kubernetes.
**Duration**: 5 min
**Slides**: Why Kubernetes? · Kubernetes Architecture
**Demo**: No demo

**Slide content**:
- Single-host Compose limits: no automatic failover, no horizontal scaling across machines, no built-in rolling deploys
- **Kubernetes**: a cluster operating system — schedules containers across nodes; continuously reconciles desired ↔ actual state
- **Control plane**: API Server (single entry point), etcd (state store), Scheduler (pod placement), Controller Manager (reconciliation)
- **Worker node**: kubelet (runs pod specs), kube-proxy (network rules), container runtime (executes containers via CRI)

**References**:
- [Kubernetes overview](https://kubernetes.io/docs/concepts/overview/) — what Kubernetes is and the problems it solves
- [Kubernetes components](https://kubernetes.io/docs/concepts/overview/components/) — full list of control-plane and node components

**Media**:
- [use] [Kubernetes cluster architecture diagram](https://kubernetes.io/images/docs/kubernetes-cluster-architecture.svg) — official diagram showing control plane, worker nodes, and their components

---

### Section 9 — K8s Core Concepts

**Teaching goal**: Audience understands Namespaces, Pods, Deployments, Services, ConfigMaps, Secrets,
and PersistentVolumeClaims at the level needed to read and follow the upcoming live demo
manifests — not as comprehensive K8s curriculum, but as the minimum vocabulary for the
showcase.
**Narrative**: Before the live demo, the audience needs just enough K8s vocabulary — Pods, Deployments, Services, ConfigMaps, Secrets, PVCs — to follow the manifest walkthrough without getting lost.
**Duration**: 7 min
**Slides**: Namespaces · The Pod · Deployments · Services · ConfigMaps & Secrets · Persistent Volumes
**Demo**: No demo

**Slide content**:
- **Namespace**: virtual cluster within a cluster — isolates resources by team, environment, or app; `kubectl get pods -n <namespace>`
- **Pod**: smallest schedulable unit; 1+ containers sharing a network namespace and volumes; ephemeral — replaced, not repaired
- **Deployment**: owns a ReplicaSet; declares desired replica count + rolling update strategy; self-heals on pod failure
- **Service**: stable virtual IP + DNS name for a dynamic pod set selected by labels; ClusterIP (internal), NodePort (reachable from host)
- **ConfigMap / Secret**: inject non-sensitive config (ConfigMap) or sensitive values (Secret) as env vars or mounted files
- **PVC**: requests storage from the cluster; bound PV survives pod deletion — how PostgreSQL persists data in the demo

**References**:
- [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) — isolation, resource scoping, and when to use multiple namespaces
- [Pods](https://kubernetes.io/docs/concepts/workloads/pods/) — lifecycle, spec, and multi-container patterns
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) — ReplicaSet ownership, rolling updates, rollback
- [Services](https://kubernetes.io/docs/concepts/services-networking/service/) — ClusterIP, NodePort, LoadBalancer types
- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/) and [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) — creation and injection patterns
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) — PV, PVC, and StorageClass lifecycle

**Media**:
- [use] [Kubernetes cluster architecture diagram](https://kubernetes.io/images/docs/kubernetes-cluster-architecture.svg) — focus on the worker-node section to show where pods are scheduled

---

### Section 10 — LIVE DEMO: Deploy to Cluster

**Teaching goal**: Audience sees the `lunchdemo` application — already familiar from the
Docker sections — deployed and running on a local Kubernetes cluster, and understands how
each Compose construct maps to a K8s resource.
**Narrative**: With the vocabulary established, the audience watches the familiar `lunchdemo` application deployed end-to-end on a local cluster, making every abstract K8s concept concrete.
**Duration**: 10 min
**Slides**: Compose → Kubernetes Mapping (intro) + live terminal
**Demo**: Demo checkpoint 1 — Full end-to-end demo: build, run, dev inner loop, deploy to Kubernetes

**Slide content**:
- **Compose → K8s mapping**: `service:` → Deployment + Service; `depends_on:` → readiness probe; `volumes:` → PVC; `environment:` → ConfigMap / Secret
- `kubectl apply -f k8s/`: applies all manifests declaratively and idempotently — safe to re-run
- Verify: `kubectl get pods -n lunchdemo` (all Running) → `kubectl get services -n lunchdemo` (NodePort assigned) → `kubectl port-forward svc/nginx 8080:80 -n lunchdemo` → open `http://localhost:8080` in browser
- The same app you built step-by-step in Docker is now running on a Kubernetes cluster

**References**:
- [kubectl apply](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_apply/) — declarative object management
- [Colima Kubernetes](https://github.com/abiosoft/colima/blob/main/docs/KUBERNETES.md) — enabling K8s in Colima, shared container runtime

**Media**:
- [use] Compose → Kubernetes Mapping table from `slides.md` (Compose → Kubernetes Mapping slide) — already authored; reuse as the demo intro slide
- [create] Deployment flow diagram: `kubectl apply` → API Server → etcd (state stored) → Scheduler → kubelet → container runtime → running pod

---

### Section 11 — Useful Tools & Resources

**Teaching goal**: Audience leaves with a curated, immediately actionable list of ecosystem
tools (management UIs, local cluster options, networking utilities) and official resources
to continue learning after the session.
**Narrative**: The core content is complete; this section equips the audience with a curated toolkit and learning path so they can continue independently after the session.
**Duration**: 4 min
**Slides**: Summary · Resources & Next Steps
**Demo**: No demo

**Slide content**:
- **Cluster UIs**: [Lens](https://k8slens.dev/) (GUI cluster IDE), [k9s](https://k9scli.io/) (terminal-based real-time view)
- **Homelabs & small VM fleets**: [Portainer](https://www.portainer.io/) — web UI for managing Docker (and Swarm/K8s) across one or more hosts; great for teams not yet on Kubernetes
- **Local cluster alternatives**: [kind](https://kind.sigs.k8s.io/) (K8s in Docker container nodes), [k3d](https://k3d.io/) (k3s in Docker, fastest spin-up)
- **Interactive playgrounds** (no local install): [Play with Docker](https://labs.play-with-docker.com/), [Play with Kubernetes](https://labs.play-with-k8s.com/)
- **Learning paths**: [Docker Docs](https://docs.docker.com/), [Kubernetes Docs](https://kubernetes.io/docs/home/), [CNCF Landscape](https://landscape.cncf.io/)

**References**:
- [Lens](https://k8slens.dev/) — Kubernetes IDE with cluster management GUI
- [k9s](https://k9scli.io/) — terminal-based Kubernetes UI with real-time cluster monitoring
- [Portainer](https://www.portainer.io/) — web UI for managing Docker, Swarm, and Kubernetes across multiple hosts; ideal for homelabs and small VM fleets
- [kind](https://kind.sigs.k8s.io/) — run local Kubernetes clusters using Docker container nodes
- [k3d](https://k3d.io/) — run k3s (lightweight Kubernetes) clusters in Docker; fastest local cluster option
- [Play with Docker](https://labs.play-with-docker.com/) — free browser-based Docker playground; no install required
- [CNCF Landscape](https://landscape.cncf.io/) — interactive map of the entire cloud-native ecosystem

**Media**:
- [create] Tool cards grid (2×3): each card shows tool name, one-sentence description, and URL — no external diagram required

---

### Section 12 — Q&A

**Teaching goal**: Audience can ask questions, explore specific use cases, and understand
how these workflows apply to their team's upcoming projects.
**Narrative**: Session content delivered — this section gives the audience space to connect the material to their own context through open questions.
**Duration**: 4 min
**Slides**: Thank You!
**Demo**: No demo

---

### Outline Summary

| # | Section | Duration | Demo |
|---|---------|----------|------|
| 1 | The "It Works on My Machine" Problem | 4 min | No demo |
| 2 | Containers vs. Virtual Machines | 4 min | No demo |
| 3 | The Container Ecosystem | 8 min | No demo |
| 4 | Docker Architecture & Images | 4 min | No demo |
| 5 | Dockerfiles & Best Practices | 5 min | No demo |
| 6 | Core CLI, Networking & Volumes | 5 min | No demo |
| 7 | Docker Compose | 5 min | No demo |
| 8 | Why Kubernetes? & K8s Architecture | 5 min | No demo |
| 9 | K8s Core Concepts | 7 min | No demo |
| 10 | LIVE DEMO: Deploy to Cluster | 10 min | Demo checkpoint 1 |
| 11 | Useful Tools & Resources | 4 min | No demo |
| 12 | Q&A | 4 min | No demo |
| | **Total** | **65 min** | |

---

## Part 2 — Demos

> Operational reference for presenters. Run `bash demo/reset.sh` before the session to ensure a clean state.

The single demo checkpoint runs at the end of the presentation (§10) and walks through the full `lunchdemo` arc in one live session: build all images → run the stack with Compose → dev inner loop (modify + rebuild one service) → bring down and deploy to Kubernetes.

---

### Demo Checkpoint 1 — Full `lunchdemo` walkthrough

**Section**: §10 — LIVE DEMO: Deploy to Cluster
**Concept illustrated**: Dockerfile + multi-stage build; `docker compose build`; declarative stack; dev inner loop; Compose → K8s resource mapping; `kubectl apply`
**Inherited state**: Clean Docker install; no `lunchdemo` images or containers exist; Colima running with Kubernetes enabled

**Prerequisites**:
- Docker Engine ≥ 26 (`docker --version`)
- Compose plugin ≥ 2 (`docker compose version`)
- Colima ≥ 0.6 with Kubernetes enabled (`colima status`)
- kubectl ≥ 1.30 (`kubectl version --client`)
- Colima K8s pre-started before the session: `colima start --kubernetes` (takes ~2 min on first run)

**Steps**:

1. **Build all service images**
   ```bash
   cd demo && docker compose build
   ```
   Point out the two-stage `api/Dockerfile` and the `image:` tags in `docker-compose.yml` that name both images exactly as the K8s manifests expect. Run a second time to show all layers `CACHED`.

2. **Start the full stack**
   ```bash
   docker compose --env-file .env up -d
   docker compose ps
   ```
   Expected: all three services (`nginx`, `api`, `db`) healthy. Open `http://localhost` in a browser.

3. **Dev inner loop — add structured logging**

   Show the current plain-text logs, then swap in the v2 source files:
   ```bash
   docker compose logs api | head -5

   cp demo/api/app_v2.py demo/api/app.py
   cp demo/api/requirements_v2.txt demo/api/requirements.txt

   docker compose build api && docker compose up -d --no-deps api
   docker compose logs api | head -5
   ```
   Expected: logs become structured JSON. Only the `api` container restarted; `db` and `nginx` kept running.

4. **Bring down the Compose stack**
   ```bash
   docker compose down
   ```

5. **Walk through the K8s manifests**
   ```bash
   ls demo/k8s/
   ```
   Briefly cover: `00-namespace.yaml` · `configmap.yaml` (non-sensitive config) · `secret.yaml` (DB password) · `api-deployment.yaml` + `api-service.yaml` · `nginx-deployment.yaml` + `nginx-service.yaml` · `db-statefulset.yaml` + `db-service.yaml` + `db-pvc.yaml`.

6. **Apply all manifests**
   ```bash
   kubectl apply -f demo/k8s/
   ```
   Expected: each resource listed as `created`.

7. **Wait for pods and inspect services**
   ```bash
   kubectl get pods -n lunchdemo --watch
   kubectl get services -n lunchdemo
   ```
   Wait until all pods show `Running`, then press `Ctrl+C`.

8. **Expose the app and open it**
   ```bash
   kubectl port-forward svc/nginx 8080:80 -n lunchdemo
   ```
   Open `http://localhost:8080` — the same app that ran in Docker is now running on Kubernetes.

**Fallback**: If Colima K8s is slow, show a pre-recorded `kubectl get pods -n lunchdemo` output with all pods `Running` and a browser screenshot. Describe each `kubectl apply` step verbally while showing the manifest files on screen.

**Resulting state**: Full 3-tier `lunchdemo` application running on Colima Kubernetes; reachable in a browser via `kubectl port-forward`. SC-005 achieved.
