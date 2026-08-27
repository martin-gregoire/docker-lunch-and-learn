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
| Colima | 0.6+ | `colima version` |
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

**Expected outcome**: 12 sections; 1 section shows a checkpoint reference (§10); 11 show "No demo"; 0 blank or missing. Section time totals fall within 55–70 minutes.

---

## Validation 3 — Demo Chain Integrity

Not applicable — there is only one checkpoint.

---

## Validation 4 — Demo Checkpoint 1 (Full walkthrough)

**Run from repo root. Ensure a clean state first: `bash demo/reset.sh`**

```bash
# Step 1: Build
cd demo && docker compose build
docker images lunchdemo-api lunchdemo-nginx

# Step 2: Run
docker compose up -d
sleep 15
docker compose ps
curl http://localhost/api/items

# Step 3: Dev inner loop
docker compose logs api | head -5
cp demo/api/app_v2.py demo/api/app.py
cp demo/api/requirements_v2.txt demo/api/requirements.txt
docker compose build api && docker compose up -d --no-deps api
docker compose logs api | head -5

# Step 4: Deploy to Kubernetes
docker compose down
kubectl apply -f demo/k8s/
kubectl wait --for=condition=ready pod -l app=api -n lunchdemo --timeout=120s
kubectl wait --for=condition=ready pod -l app=nginx -n lunchdemo --timeout=120s
kubectl wait --for=condition=ready pod -l app=db -n lunchdemo --timeout=120s
kubectl get pods -n lunchdemo
kubectl port-forward svc/nginx 8080:80 -n lunchdemo &
sleep 3 && curl http://localhost:8080/api/items
```

**Expected outcome**:
- Both images built; `lunchdemo-api:1.0` under 300 MB.
- All 3 Compose services healthy; `curl http://localhost/api/items` returns JSON.
- API logs become structured JSON after the rebuild.
- All K8s pods `Running`; `curl http://localhost:8080/api/items` returns JSON.

**Teardown**:
```bash
kill %1 2>/dev/null
kubectl delete -f demo/k8s/
git checkout demo/api/app.py demo/api/requirements.txt
```

---

## Validation 5 — Plan-First Governance (Manual)

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
| 2 — Demo indicator coverage | 12 sections; 1 with checkpoint ref (§10); 11 "No demo"; 0 blank | ☐ |
| 3 — Demo chain integrity | N/A — single checkpoint | ✔ |
| 4 — Checkpoint 1 | All steps pass end-to-end; K8s pods Running; app accessible | ☐ |
| 5 — Plan-first governance | 0 orphan slide headings; plan date ≥ slides date | ☐ |
