#!/usr/bin/env bash
# Resets the demo environment to a clean state for a fresh run from Demo Checkpoint 1.
set -euo pipefail

echo "==> Stopping Compose stack (if running)..."
docker compose -f "$(dirname "$0")/docker-compose.yml" down -v --remove-orphans 2>/dev/null || true

echo "==> Removing demo containers (if any)..."
docker rm -f api db nginx lunchdemo-api lunchdemo-db 2>/dev/null || true

echo "==> Removing lunchdemo images..."
docker rmi -f lunchdemo-api:1.0 lunchdemo-nginx:1.0 2>/dev/null || true

echo "==> Removing lunchdemo network and volumes..."
docker network rm lunchdemo-net 2>/dev/null || true
docker volume rm lunchdemo-pgdata 2>/dev/null || true

echo "==> Removing Kubernetes namespace (if exists)..."
kubectl delete namespace lunchdemo --ignore-not-found 2>/dev/null || true

echo ""
echo "==> Verifying clean state..."
echo "Containers:"
docker ps -a --format "  {{.Names}}: {{.Status}}" | grep -v "^  k8s_" || echo "  (none)"
echo "lunchdemo images:"
docker images --filter=reference="lunchdemo*" --format "  {{.Repository}}:{{.Tag}}" || echo "  (none)"
echo "Custom networks:"
docker network ls --filter type=custom --format "  {{.Name}}" || echo "  (none)"
echo "K8s lunchdemo namespace:"
kubectl get ns lunchdemo 2>&1 | grep -v "^Error" || echo "  (none)"

echo ""
echo "Done. Environment is clean — ready to start from Demo Checkpoint 1."
