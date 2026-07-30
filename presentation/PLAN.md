# Docker & Containerization — Lunch and Learn: Presentation Plan

**Target Duration**: 55–70 minutes
**Audience**: Software Developers & Quality Engineers
**Last Updated**: 2026-07-30

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
**Duration**: 4 min
**Slides**: The Problem
**Demo**: No demo

---

### Section 2 — Containers vs. Virtual Machines

**Teaching goal**: Audience understands what a container is structurally — shared kernel,
isolated process namespace — why it is lighter and faster than a VM, and when each
approach is appropriate.
**Duration**: 4 min
**Slides**: VMs vs Containers
**Demo**: No demo

---

### Section 3 — The Container Ecosystem

**Teaching goal**: Audience understands the Linux primitives (namespaces, cgroups) that make
container isolation possible, what the Container Runtime Interface (CRI) standardises, and
why Docker is one of several interchangeable runtimes alongside Podman, containerd, and CRI-O.
**Duration**: 6 min
**Slides**: new slides needed — Linux namespaces & cgroups · CRI overview · Docker alternatives table
**Demo**: No demo

---

### Section 4 — Docker Architecture & Images

**Teaching goal**: Audience understands the Daemon–CLI–Registry triangle, how the Docker
daemon manages images and containers, and what a layered image filesystem is.
**Duration**: 4 min
**Slides**: Docker Architecture · Docker Images
**Demo**: No demo

---

### Section 5 — Dockerfiles & Best Practices

**Teaching goal**: Audience can read and write a basic Dockerfile; understands multi-stage
builds, layer caching, and why containers should run as a non-root user.
**Duration**: 5 min
**Slides**: The Dockerfile · Dockerfile Best Practices
**Demo**: Demo checkpoint 1 — Build the `lunchdemo` API image

---

### Section 6 — Core CLI, Networking & Volumes

**Teaching goal**: Audience knows the essential `docker` commands for the daily workflow,
understands how containers on a custom bridge network reach each other by name, and how
named volumes provide persistent storage that survives container removal.
**Duration**: 5 min
**Slides**: Core CLI Commands · Networking · Volumes
**Demo**: Demo checkpoint 2 — Pull and run PostgreSQL; connect the API via a custom network

---

### Section 7 — Docker Compose

**Teaching goal**: Audience understands how to define a multi-container stack declaratively
with a single YAML file, build service images with Compose, and iterate through the
developer inner loop (add a dependency → rebuild one service → verify) without
restarting the entire stack.
**Duration**: 5 min
**Slides**: Why Docker Compose? · Docker Compose YAML · Compose Commands Cheat-Sheet
**Demo**: Demo checkpoint 3 — Bring up the full 3-tier stack; add `python-json-logger` and rebuild only the API

---

### Section 8 — Why Kubernetes? & K8s Architecture

**Teaching goal**: Audience understands the limitations of single-host Compose at production
scale and what problem Kubernetes solves; can describe the control-plane / worker-node split
at a conceptual level.
**Duration**: 5 min
**Slides**: Why Kubernetes? · Kubernetes Architecture
**Demo**: No demo

---

### Section 9 — K8s Core Concepts

**Teaching goal**: Audience understands Pods, Deployments, Services, ConfigMaps, Secrets,
and PersistentVolumeClaims at the level needed to read and follow the upcoming live demo
manifests — not as comprehensive K8s curriculum, but as the minimum vocabulary for the
showcase.
**Duration**: 7 min
**Slides**: The Pod · Deployments · Services · ConfigMaps & Secrets · Persistent Volumes
**Demo**: No demo

---

### Section 10 — LIVE DEMO: Deploy to Cluster

**Teaching goal**: Audience sees the `lunchdemo` application — already familiar from the
Docker sections — deployed and running on a local Kubernetes cluster, and understands how
each Compose construct maps to a K8s resource.
**Duration**: 10 min
**Slides**: Compose → Kubernetes Mapping (intro) + live terminal
**Demo**: Demo checkpoint 4 — Deploy the full 3-tier app to minikube; verify it is reachable

---

### Section 11 — Useful Tools & Resources

**Teaching goal**: Audience leaves with a curated, immediately actionable list of ecosystem
tools (management UIs, local cluster options, networking utilities) and official resources
to continue learning after the session.
**Duration**: 4 min
**Slides**: Summary · Resources & Next Steps
**Demo**: No demo

---

### Section 12 — Q&A

**Teaching goal**: Audience can ask questions, explore specific use cases, and understand
how these workflows apply to their team's upcoming projects.
**Duration**: 4 min
**Slides**: Thank You!
**Demo**: —

---

### Outline Summary

| # | Section | Duration | Demo |
|---|---------|----------|------|
| 1 | The "It Works on My Machine" Problem | 4 min | No demo |
| 2 | Containers vs. Virtual Machines | 4 min | No demo |
| 3 | The Container Ecosystem | 6 min | No demo |
| 4 | Docker Architecture & Images | 4 min | No demo |
| 5 | Dockerfiles & Best Practices | 5 min | Demo checkpoint 1 |
| 6 | Core CLI, Networking & Volumes | 5 min | Demo checkpoint 2 |
| 7 | Docker Compose | 5 min | Demo checkpoint 3 |
| 8 | Why Kubernetes? & K8s Architecture | 5 min | No demo |
| 9 | K8s Core Concepts | 7 min | No demo |
| 10 | LIVE DEMO: Deploy to Cluster | 10 min | Demo checkpoint 4 |
| 11 | Useful Tools & Resources | 4 min | No demo |
| 12 | Q&A | 4 min | — |
| | **Total** | **63 min** | |

---

## Part 2 — Demos

> Operational reference for presenters. Each checkpoint builds on the state left by the
> previous one. Do not skip a checkpoint — later steps depend on artifacts created earlier.

*(Demo checkpoints to be added — see tasks T019–T022)*
