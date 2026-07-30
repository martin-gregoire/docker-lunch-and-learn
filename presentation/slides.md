---
theme: seriph
background: https://cover.sli.dev
title: Docker & Containerization — Lunch and Learn
info: |
  ## Docker Lunch & Learn
  A deep-dive into Containerization, Docker Compose, and Kubernetes.
class: text-center
highlighter: shiki
drawings:
  persist: false
transition: slide-left
mdc: true
colorSchema: dark
---

# 🐳 Docker & Containerization

### From a single container to a production cluster

<div class="pt-12 text-gray-400">
  Press <kbd>Space</kbd> to advance
</div>

---
layout: default
---

# Agenda

<div class="grid grid-cols-2 gap-8 mt-4">
<div>

**Part 1 — Docker**
1. The problem containers solve
2. Containers vs Virtual Machines
3. Docker architecture
4. Images & the Dockerfile
5. Core CLI commands
6. Networking & Volumes

</div>
<div>

**Part 2 — Orchestration**

7. Docker Compose
8. Why Kubernetes?
9. K8s architecture
10. Pods, Deployments & Services
11. ConfigMaps, Secrets & PVs
12. kubectl & YAML manifests
13. Deployment strategies

</div>
</div>

---
layout: two-cols
---

# The Problem

> "It works on my machine!" 🤷

**Without containers you deal with:**

- Conflicting runtime versions (Node 18 vs 20)
- OS-level dependency drift
- Snowflake servers nobody dares touch
- Manual, error-prone deployments
- Long onboarding times for new devs

::right::

```bash
# Monday morning, new team member
$ npm install
error: node@20 required, found node@14

$ pip install -r requirements.txt
error: incompatible platform (Linux required)

$ ./start.sh
error: postgres 15 not found

# Three hours later…
$ echo "I'll just use my colleague's laptop"
```

---
layout: two-cols
---

# VMs vs Containers

**Virtual Machines**

```
┌──────────────────────┐
│      App A           │
│   (Node 18 + deps)   │
│   Guest OS (Ubuntu)  │
├──────────────────────┤
│      App B           │
│   (Python 3.11)      │
│   Guest OS (Debian)  │
├──────────────────────┤
│      Hypervisor      │
│    Host OS + HW      │
└──────────────────────┘
  Heavy (~GBs), slow boot
```

::right::

**Containers**

```
┌────────┬─────────────┐
│ App A  │   App B     │
│Node 18 │ Python 3.11 │
├────────┴─────────────┤
│  Container Runtime   │
│  (Docker / containerd)
├──────────────────────┤
│    Host OS Kernel    │
│    Hardware          │
└──────────────────────┘
  Lightweight (~MBs), instant
```

---

# Docker Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Docker CLI  (docker build / run / push…)                    │
└────────────────────┬────────────────────────────────────────┘
                     │ REST API
┌────────────────────▼────────────────────────────────────────┐
│               Docker Daemon  (dockerd)                       │
│                                                              │
│   ┌─────────────┐   ┌──────────────┐   ┌─────────────────┐  │
│   │   Images    │   │  Containers  │   │   Networks /    │  │
│   │  (read-only)│   │  (running)   │   │   Volumes       │  │
│   └─────────────┘   └──────────────┘   └─────────────────┘  │
└──────────────────────────────────┬──────────────────────────┘
                                   │ pulls / pushes
                     ┌─────────────▼─────────────┐
                     │   Registry (Docker Hub /   │
                     │   GHCR / ECR / ACR…)       │
                     └────────────────────────────┘
```

---
layout: two-cols
---

# Docker Images

An image is a **read-only, layered filesystem** built from a `Dockerfile`.

- Each instruction adds a new **layer**
- Layers are **cached** and **shared** between images
- An image is **immutable** — containers are ephemeral instances of it

::right::

```
Image: myapp:1.0
├── Layer 4  COPY ./src /app/src      ← your code
├── Layer 3  RUN npm ci               ← deps installed
├── Layer 2  COPY package*.json .     ← package files
└── Layer 1  FROM node:20-alpine      ← base OS
```

```bash
# List local images
docker images

# Pull from registry
docker pull node:20-alpine

# Inspect image layers
docker history myapp:1.0
```

---

# The Dockerfile

```dockerfile
# syntax=docker/dockerfile:1

# ── Stage 1: build ────────────────────────────────────
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
# Mount cache to avoid re-downloading on every build
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

COPY . .
RUN npm run build

# ── Stage 2: production image ─────────────────────────
FROM node:20-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app

# Drop to non-root for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=build --chown=appuser:appgroup /app/dist ./dist
COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules

USER appuser
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

---

# Dockerfile Best Practices

<div class="grid grid-cols-2 gap-6">
<div>

✅ **Do**
- Use **multi-stage builds** to keep images small
- Pin base image versions (`node:20.11-alpine`)
- Run as a **non-root user**
- Use `.dockerignore` to exclude `node_modules`, `.git`
- Leverage **build cache** — copy lock files before source
- Use `--mount=type=cache` for package managers
- Set `HEALTHCHECK` for orchestrators

</div>
<div>

❌ **Don't**
- `RUN apt-get update` without `apt-get install` in the same layer
- Store secrets in `ENV` or `COPY` them into layers
- Run as `root` in production
- Use `latest` tag for base images in production
- Install unnecessary tools (`curl`, `vim`) in runtime stage
- Chain many `RUN` layers without purpose

</div>
</div>

---

# Core CLI Commands

```bash
# ── Build ──────────────────────────────────────────────────
docker build -t myapp:1.0 .            # build from Dockerfile
docker build --target build .          # stop at a named stage

# ── Run ────────────────────────────────────────────────────
docker run myapp:1.0                   # basic run
docker run -d -p 3000:3000 myapp:1.0  # detached, port mapped
docker run -e DB_URL=postgres://... \  # env var injection
  -v $(pwd)/data:/app/data myapp:1.0  # bind mount

# ── Inspect & Debug ────────────────────────────────────────
docker ps                              # running containers
docker ps -a                           # all containers
docker logs -f <container>             # stream logs
docker exec -it <container> sh        # shell into container
docker stats                           # live resource usage

# ── Lifecycle ──────────────────────────────────────────────
docker stop <container>
docker rm <container>
docker rmi myapp:1.0                   # remove image
docker system prune -af               # clean everything
```

---
layout: two-cols
---

# Networking

Docker provides **built-in network drivers**:

| Driver | Use case |
|--------|----------|
| `bridge` | Default; containers on same host |
| `host` | Share host network stack |
| `none` | Fully isolated |
| `overlay` | Multi-host (Swarm/K8s) |

Containers on the **same bridge network** can reach each other by **container name**.

::right::

```bash
# Create a custom network
docker network create mynet

# Attach containers to it
docker run -d --network mynet \
  --name db postgres:16

docker run -d --network mynet \
  --name api myapp:1.0

# api can now reach db at postgres://db:5432
# (not just localhost — container name DNS!)

docker network ls
docker network inspect mynet
```

---
layout: two-cols
---

# Volumes

Containers are **ephemeral** — filesystem changes are lost when a container is removed.

**Volumes** provide persistent, managed storage:

| Type | Use case |
|------|----------|
| Named volume | Managed by Docker; best for databases |
| Bind mount | Map host path; best for dev hot-reload |
| tmpfs mount | In-memory; ephemeral sensitive data |

::right::

```bash
# Named volume (Docker manages the path)
docker volume create pgdata

docker run -d \
  -v pgdata:/var/lib/postgresql/data \
  postgres:16

# Bind mount (host path → container path)
docker run -d \
  -v $(pwd)/src:/app/src \
  myapp:dev

# Inspect & clean
docker volume ls
docker volume inspect pgdata
docker volume prune
```

---
layout: cover
background: https://cover.sli.dev
---

# Part 2: Orchestration

### Docker Compose → Kubernetes

---

# Why Docker Compose?

Running one container is easy. A real app has many:

```
Web server  ──►  API service  ──►  Database
                     │
                     └──►  Cache (Redis)
                     │
                     └──►  Message queue (RabbitMQ)
```

**Without Compose**, you'd run 5 `docker run` commands with the right flags, networks, and env vars — in the right order, every time.

**With Compose**, a single `docker-compose.yml` defines the entire stack declaratively.

```bash
docker compose up -d       # start everything
docker compose down        # stop and remove
docker compose logs -f api # stream a service's logs
```

---

# Docker Compose YAML

```yaml
# docker-compose.yml
services:
  api:
    build: ./api                   # build from local Dockerfile
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:secret@db:5432/app
      - REDIS_URL=redis://cache:6379
    depends_on:
      db:
        condition: service_healthy  # wait for health check to pass
    networks: [backend]

  db:
    image: postgres:16-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: secret
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      retries: 5
    networks: [backend]

  cache:
    image: redis:7-alpine
    networks: [backend]

volumes:
  pgdata:

networks:
  backend:
```

---

# Compose Commands Cheat-Sheet

```bash
# ── Lifecycle ──────────────────────────────────────────────
docker compose up -d              # start all services (detached)
docker compose up --build         # rebuild images before starting
docker compose down               # stop + remove containers & networks
docker compose down -v            # also remove volumes

# ── Scaling ────────────────────────────────────────────────
docker compose up -d --scale api=3   # run 3 api replicas

# ── Inspection ─────────────────────────────────────────────
docker compose ps                 # list services
docker compose logs -f            # all service logs
docker compose logs -f api        # single service
docker compose top                # processes running inside

# ── One-off commands ───────────────────────────────────────
docker compose exec api sh        # shell into running service
docker compose run --rm api npm test  # run command in new container

# ── Config ─────────────────────────────────────────────────
docker compose config             # print resolved config
```

---

# Why Kubernetes?

Compose is great for a **single host**. Production needs more:

| Challenge | Kubernetes answer |
|-----------|-------------------|
| Container dies | Automatic **self-healing** (restarts) |
| Traffic spike | Horizontal **auto-scaling** (HPA) |
| Zero-downtime deploy | **Rolling updates** |
| Multiple nodes | **Cluster scheduling** |
| Service discovery | Built-in **DNS + load balancing** |
| Secret management | Native **Secrets** API |
| Storage | **PersistentVolumes** with dynamic provisioning |

> K8s is essentially **Docker Compose at datacenter scale**, with built-in resilience.

---

# Kubernetes Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  Control Plane (master nodes)                                    │
│                                                                  │
│  ┌──────────────┐ ┌──────────────┐ ┌───────────┐ ┌──────────┐  │
│  │  API Server  │ │   etcd       │ │ Scheduler │ │Controller│  │
│  │ (kubectl →)  │ │ (state store)│ │           │ │ Manager  │  │
│  └──────────────┘ └──────────────┘ └───────────┘ └──────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │
          ┌──────────────────┼───────────────────┐
          │                  │                   │
┌─────────▼──────┐  ┌────────▼───────┐  ┌────────▼───────┐
│   Worker Node  │  │  Worker Node   │  │  Worker Node   │
│                │  │                │  │                │
│  ┌──────────┐  │  │  ┌──────────┐  │  │  ┌──────────┐  │
│  │  kubelet │  │  │  │  kubelet │  │  │  │  kubelet │  │
│  │  kube-   │  │  │  │  kube-   │  │  │  │  kube-   │  │
│  │  proxy   │  │  │  │  proxy   │  │  │  │  proxy   │  │
│  │  runtime │  │  │  │  runtime │  │  │  │  runtime │  │
│  └──────────┘  │  │  └──────────┘  │  │  └──────────┘  │
└────────────────┘  └────────────────┘  └────────────────┘
```

---

# The Pod — Smallest Unit

A **Pod** wraps one or more containers that share:
- Network namespace (same IP, ports)
- Storage volumes
- Lifecycle

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: api-pod
  labels:
    app: api
spec:
  containers:
    - name: api
      image: myapp:1.0
      ports:
        - containerPort: 3000
      env:
        - name: NODE_ENV
          value: production
      resources:
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "500m"
          memory: "512Mi"
      livenessProbe:
        httpGet:
          path: /healthz
          port: 3000
        initialDelaySeconds: 10
        periodSeconds: 15
```

---

# Deployments

You **never create Pods directly** in production. A **Deployment** manages a set of identical Pods:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 3                       # desired pod count
  selector:
    matchLabels:
      app: api
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1                   # one extra pod during update
      maxUnavailable: 0             # keep all pods running during update
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
        - name: api
          image: myapp:1.0
          ports:
            - containerPort: 3000
```

---

# Services

Pods are ephemeral and get new IPs. A **Service** provides a **stable DNS name + load-balanced IP** in front of a set of Pods.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api
spec:
  selector:
    app: api          # matches Deployment's pod labels
  ports:
    - port: 80
      targetPort: 3000
  type: ClusterIP     # internal only
```

| Service Type | Reachable from | Use case |
|---|---|---|
| `ClusterIP` | Inside cluster only | Inter-service communication |
| `NodePort` | Any node's IP | Dev / simple external access |
| `LoadBalancer` | Internet (cloud LB) | Production external traffic |
| `Ingress` | Internet via HTTP rules | Virtual hosting, TLS, path routing |

---
layout: two-cols
---

# ConfigMaps & Secrets

**ConfigMap** — non-sensitive config

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
data:
  LOG_LEVEL: "info"
  PORT: "3000"
  FEATURE_X: "true"
```

Use in a Pod:

```yaml
envFrom:
  - configMapRef:
      name: api-config
```

::right::

**Secret** — sensitive data (base64-encoded at rest)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: api-secrets
type: Opaque
stringData:               # K8s encodes automatically
  DATABASE_PASSWORD: "s3cr3t"
  JWT_SECRET: "supersecretkey"
```

Use in a Pod:

```yaml
env:
  - name: DATABASE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: api-secrets
        key: DATABASE_PASSWORD
```

> In production, use **Sealed Secrets**, **External Secrets Operator**, or a vault.

---
layout: two-cols
---

# Persistent Volumes

Stateful apps (databases) need durable storage.

**PersistentVolumeClaim (PVC)** — a request for storage

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

::right::

Mount in a Pod:

```yaml
spec:
  containers:
    - name: postgres
      image: postgres:16
      volumeMounts:
        - mountPath: /var/lib/postgresql/data
          name: pgdata
  volumes:
    - name: pgdata
      persistentVolumeClaim:
        claimName: postgres-pvc
```

> For databases on K8s, prefer a **StatefulSet** over a Deployment — it gives each pod a stable identity and ordered rollout.

---

# kubectl Cheat-Sheet

```bash
# ── Apply / Delete ─────────────────────────────────────────────
kubectl apply -f manifest.yaml          # create or update
kubectl delete -f manifest.yaml
kubectl apply -k ./overlays/prod/       # Kustomize

# ── Inspection ─────────────────────────────────────────────────
kubectl get pods                        # list pods
kubectl get all -n my-namespace
kubectl describe pod api-7f8d9c-xkz    # detailed pod info
kubectl logs -f api-7f8d9c-xkz
kubectl exec -it api-7f8d9c-xkz -- sh  # shell into pod
kubectl top pods                        # CPU / memory usage

# ── Deployments ────────────────────────────────────────────────
kubectl rollout status deploy/api
kubectl rollout history deploy/api
kubectl rollout undo deploy/api         # roll back

# ── Scaling ────────────────────────────────────────────────────
kubectl scale deploy/api --replicas=5
kubectl autoscale deploy/api --min=2 --max=10 --cpu-percent=70
```

---

# Deployment Strategies

<div class="grid grid-cols-3 gap-4 text-sm mt-4">

<div class="border border-gray-600 rounded p-3">

**RollingUpdate** *(default)*

Gradually replaces old pods with new ones.

- Zero downtime ✅
- Both versions run simultaneously
- Easy rollback ✅

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

</div>

<div class="border border-gray-600 rounded p-3">

**Recreate**

Terminates all old pods before starting new ones.

- Brief downtime ⚠️
- Clean cut-over
- Useful when two versions cannot coexist

```yaml
strategy:
  type: Recreate
```

</div>

<div class="border border-gray-600 rounded p-3">

**Blue / Green** *(external tool)*

Two identical environments; flip traffic instantly.

- Zero downtime ✅
- Instant rollback ✅
- Double infra cost ⚠️

Use **Argo Rollouts** or **Flagger** for automated canary + blue/green on K8s.

</div>

</div>

---

# Full Stack Example — YAML

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: myapp
---
# deployment.yaml + service.yaml (abbreviated)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: myapp
spec:
  replicas: 2
  selector:
    matchLabels: { app: api }
  template:
    metadata:
      labels: { app: api }
    spec:
      containers:
        - name: api
          image: ghcr.io/myorg/api:v1.2.3
          envFrom:
            - configMapRef: { name: api-config }
            - secretRef:    { name: api-secrets }
---
apiVersion: v1
kind: Service
metadata: { name: api, namespace: myapp }
spec:
  selector: { app: api }
  ports: [{ port: 80, targetPort: 3000 }]
```

---
layout: two-cols
---

# Compose → Kubernetes Mapping

| Docker Compose | Kubernetes |
|---|---|
| `service` | `Deployment` + `Service` |
| `ports` | `Service` (NodePort / LB) |
| `environment` | `ConfigMap` / `Secret` |
| `volumes` (named) | `PersistentVolumeClaim` |
| `networks` | Namespace + `NetworkPolicy` |
| `depends_on` | `InitContainers` / readiness probes |
| `replicas` | `spec.replicas` on Deployment |
| `.env` file | `ConfigMap` / `Secret` |

::right::

```bash
# kompose converts Compose → K8s YAML
# (great starting point, then tune manually)

brew install kompose

kompose convert -f docker-compose.yml \
  --out ./k8s/

# Generates:
#   k8s/api-deployment.yaml
#   k8s/api-service.yaml
#   k8s/db-deployment.yaml
#   k8s/db-service.yaml
#   k8s/pgdata-persistentvolumeclaim.yaml
```

---

# Summary

<div class="grid grid-cols-3 gap-4 text-sm mt-4">

<div class="border border-blue-800 rounded p-3">

### 🐳 Docker

- Packages app + runtime into an **image**
- Runs isolated **containers** from that image
- Dockerfile = reproducible build recipe
- `.dockerignore` + multi-stage = small, secure images

</div>

<div class="border border-green-800 rounded p-3">

### 🔧 Docker Compose

- Declarative multi-container stacks
- Single YAML file, single command
- Health checks + `depends_on` for startup ordering
- Named volumes for persistence
- Ideal for **local dev** and **CI**

</div>

<div class="border border-purple-800 rounded p-3">

### ☸️ Kubernetes

- Orchestrates containers across a **cluster**
- Self-healing, auto-scaling, rolling updates
- Objects: Pod → Deployment → Service
- ConfigMap / Secret for config injection
- PVC for persistent storage

</div>

</div>

---

# Resources & Next Steps

<div class="grid grid-cols-2 gap-6">
<div>

**Official Docs**
- [docs.docker.com](https://docs.docker.com)
- [kubernetes.io/docs](https://kubernetes.io/docs/home/)
- [compose-spec.io](https://compose-spec.io)

**Hands-on**
- [Play with Docker](https://labs.play-with-docker.com/)
- [Killercoda K8s scenarios](https://killercoda.com/playgrounds/scenario/kubernetes)
- [KataCoda / O'Reilly](https://learning.oreilly.com/playlists/kubernetes/)

</div>
<div>

**Local K8s**
- [Docker Desktop](https://docs.docker.com/desktop/kubernetes/) — toggle on K8s
- [minikube](https://minikube.sigs.k8s.io/docs/) — feature-rich local cluster
- [kind](https://kind.sigs.k8s.io/) — K8s in Docker (great for CI)
- [k3s](https://k3s.io/) — lightweight, Raspberry Pi friendly

**Going Further**
- Helm — K8s package manager
- Argo CD — GitOps continuous delivery
- Prometheus + Grafana — observability
- Istio / Linkerd — service mesh

</div>
</div>

---
layout: center
class: text-center
---

# Thank You! 🐳

### Questions?

<div class="text-gray-400 mt-4 text-sm">
  Built with <a href="https://sli.dev" class="text-blue-400">Slidev</a>
</div>
