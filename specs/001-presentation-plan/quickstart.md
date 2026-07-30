# Quickstart: Validating the Presentation Plan Document

**Phase**: 1 — Design
**Date**: 2026-07-30
**Feature**: [spec.md](../spec.md) · [contracts/plan-format.md](../contracts/plan-format.md)

This guide describes how to verify that `presentation/PLAN.md` is complete and correct once implemented. Run these validations before any session delivery.

---

## Prerequisites

| Tool | Minimum version | Verify |
|------|----------------|--------|
| Docker Engine | 26.x | `docker --version` |
| Docker Compose plugin | 2.x | `docker compose version` |
| minikube | 1.33+ | `minikube version` |
| kubectl | 1.30+ | `kubectl version --client` |
| Python | 3.12+ | `python3 --version` |
| curl | any | `curl --version` |

All tools must be installed and available on `$PATH` before running any demo validation.

---

## Validation 1 — Outline Completeness

Verify the Outline section of `PLAN.md` is complete and consistent with `slides.md`.

**Steps**:

1. Open `presentation/PLAN.md` and count the Section entries in Part 1 (Outline).
2. Open `presentation/slides.md` and list every slide heading (`# …`).
3. For each slide heading in `slides.md`, confirm a corresponding Section or sub-topic entry exists in the Outline.
4. Confirm no slide heading is orphaned (present in `slides.md` but absent from the Outline).

**Expected outcome**: Every slide maps to a section; no orphan slides; no sections pointing to non-existent slides.

---

## Validation 2 — Demo Indicator Coverage

Verify every Section in the Outline has an explicit demo indicator (FR-009).

**Steps**:

1. In `PLAN.md` Part 1, find every `**Demo**:` field.
2. Confirm each value is exactly one of: `No demo`, `Demo deferred to §N — [reason]`, or `Demo checkpoint N — [label]`.
3. Confirm no `**Demo**:` field is blank, missing, or says "TBD".

**Expected outcome**: 12 sections; 4 sections show a checkpoint reference; 8 show "No demo"; 0 blank or missing. Section time totals fall within 55–70 minutes.

---

## Validation 3 — Demo Chain Integrity

Verify the inherited/resulting state chain is unbroken across all 4 checkpoints.

**Steps**:

1. In `PLAN.md` Part 2, read Demo 1's `Resulting state`.
2. Confirm Demo 2's `Inherited state` describes the same concrete artifacts.
3. Repeat for Demo 2→3 and Demo 3→4.

**Expected outcome**: Each hand-off is consistent; no demo assumes artifacts that the previous demo did not produce.

---

## Validation 4 — Demo Checkpoint 1 (Build the API image)

**Run from repo root.**

```bash
# Build the Python API image
docker build -t lunchdemo-api:1.0 ./demo/api

# Verify the image exists
docker images lunchdemo-api
```

**Expected outcome**: `lunchdemo-api:1.0` appears in `docker images` output with a size under 300 MB.

---

## Validation 5 — Demo Checkpoint 2 (Manual docker run)

**Prerequisite**: Validation 4 completed successfully.

```bash
docker network create lunchdemo-net
docker volume create lunchdemo-pgdata

docker run -d \
  --name db \
  --network lunchdemo-net \
  -v lunchdemo-pgdata:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=secret \
  postgres:16-alpine

# Wait ~5 seconds for postgres to be ready
sleep 5

docker run -d \
  --name api \
  --network lunchdemo-net \
  -e DATABASE_URL=postgresql://postgres:secret@db:5432/lunchdemo \
  -p 8000:8000 \
  lunchdemo-api:1.0

curl http://localhost:8000/api/items
```

**Expected outcome**: `curl` returns a JSON array (e.g., `[]` or sample items). HTTP 200.

**Teardown**:
```bash
docker rm -f db api
docker network rm lunchdemo-net
# Keep lunchdemo-pgdata for continuity check if desired, then:
docker volume rm lunchdemo-pgdata
```

---

## Validation 6 — Demo Checkpoint 3 (Docker Compose)

**Prerequisite**: Validation 5 teardown completed.

```bash
docker compose -f demo/docker-compose.yml up -d

# Wait for health checks
sleep 10
docker compose -f demo/docker-compose.yml ps
```

**Expected outcome**: All three services (`nginx`, `api`, `db`) show status `healthy` or `running`. Opening `http://localhost` in a browser (or `curl http://localhost`) serves the frontend HTML.

**Teardown**:
```bash
docker compose -f demo/docker-compose.yml down -v
```

---

## Validation 7 — Demo Checkpoint 4 (Deploy to minikube)

**Prerequisite**: Validation 6 teardown completed; minikube started.

```bash
minikube start

# Point shell to minikube's Docker daemon (so it can find the local image)
eval $(minikube docker-env)
docker build -t lunchdemo-api:1.0 ./demo/api

kubectl apply -f demo/k8s/

# Wait for pods to reach Running state (up to 2 minutes)
kubectl wait --for=condition=ready pod -l app=api --timeout=120s
kubectl wait --for=condition=ready pod -l app=nginx --timeout=120s
kubectl wait --for=condition=ready pod -l app=db --timeout=120s

kubectl get pods
kubectl get services

# Get the URL for the nginx NodePort service
minikube service nginx --url
```

**Expected outcome**:
- All pods show `Running` / `1/1 Ready`.
- `minikube service nginx --url` returns a localhost URL.
- Opening that URL in a browser (or `curl <url>`) serves the frontend HTML.
- `curl <url>/api/items` returns a JSON array. HTTP 200.

**Teardown**:
```bash
kubectl delete -f demo/k8s/
minikube stop
```

---

## Validation 8 — Plan-First Governance (Manual)

Verify no content exists in `slides.md` that has no corresponding entry in the Outline.

**Steps**:

1. Extract all `# [Heading]` lines from `slides.md` (excluding code block headings).
2. For each heading, confirm a Section or sub-topic in `PLAN.md` Part 1 references it.
3. Confirm `PLAN.md`'s `Last Updated` date is ≥ the last `git log --follow -1 --format=%cs presentation/slides.md` date.

**Expected outcome**: No orphan headings; plan date is current.

---

## Summary Checklist

| Validation | Criteria | Status |
|------------|----------|--------|
| 1 — Outline completeness | Every slide maps to a section; 0 orphans | ☐ |
| 2 — Demo indicator coverage | 11 sections; 4 with checkpoint refs; 0 blank | ☐ |
| 3 — Demo chain integrity | Resulting state N = Inherited state N+1 | ☐ |
| 4 — Checkpoint 1 | `lunchdemo-api:1.0` image built successfully | ☐ |
| 5 — Checkpoint 2 | API returns HTTP 200 JSON via `docker run` | ☐ |
| 6 — Checkpoint 3 | All 3 Compose services healthy; frontend accessible | ☐ |
| 7 — Checkpoint 4 | All pods Running; app accessible via minikube URL | ☐ |
| 8 — Plan-first governance | 0 orphan slide headings; plan date ≥ slides date | ☐ |
