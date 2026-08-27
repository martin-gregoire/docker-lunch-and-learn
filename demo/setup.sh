#!/usr/bin/env bash
# Ensures Colima is running with Docker + Kubernetes ready for the demo.
# Safe to run multiple times — skips steps that are already done.
set -euo pipefail

COLIMA=$(command -v colima 2>/dev/null || echo "")
DOCKER=$(command -v docker 2>/dev/null || echo "")
KUBECTL=$(command -v kubectl 2>/dev/null || echo "")

fail() { echo "ERROR: $*" >&2; exit 1; }
ok()   { echo "  ✓ $*"; }
info() { echo "  → $*"; }

echo "=== Pre-demo setup ==="
echo ""

# ── 1. Tool presence ──────────────────────────────────────────────────────────
echo "[1/4] Checking required tools..."

[[ -n "$COLIMA" ]] || fail "colima not found. Install with: brew install colima"
[[ -n "$DOCKER" ]] || fail "docker not found. Install with: brew install docker && brew link --overwrite docker"
[[ -n "$KUBECTL" ]] || fail "kubectl not found. Install with: brew install kubectl"

ok "colima  → $COLIMA"
ok "docker  → $DOCKER"
ok "kubectl → $KUBECTL"

# Fix dead Docker Desktop plugin symlinks and wire in the Homebrew compose plugin
COMPOSE_PLUGIN=~/.docker/cli-plugins/docker-compose
if [[ -L "$COMPOSE_PLUGIN" && ! -e "$COMPOSE_PLUGIN" ]] || [[ ! -e "$COMPOSE_PLUGIN" ]]; then
    for f in ~/.docker/cli-plugins/*; do
        [[ -L "$f" && ! -e "$f" ]] && rm "$f"
    done
    mkdir -p ~/.docker/cli-plugins
    BREW_COMPOSE=$(command -v docker-compose 2>/dev/null || echo "")
    [[ -n "$BREW_COMPOSE" ]] || fail "docker-compose not found. Install with: brew install docker-compose"
    ln -sf "$BREW_COMPOSE" "$COMPOSE_PLUGIN"
    info "Wired docker-compose plugin → $BREW_COMPOSE"
fi
$DOCKER compose version > /dev/null 2>&1 || fail "'docker compose' still not working. Check ~/.docker/cli-plugins/"
echo ""

# ── 2. Colima running with Kubernetes ────────────────────────────────────────
echo "[2/4] Checking Colima status..."

COLIMA_STATUS=$($COLIMA status 2>&1 || true)

if echo "$COLIMA_STATUS" | grep -q "kubernetes: enabled"; then
    ok "Colima is running with Kubernetes enabled"
elif echo "$COLIMA_STATUS" | grep -q "colima is running"; then
    info "Colima is running but Kubernetes is not enabled — restarting with --kubernetes"
    $COLIMA stop
    $COLIMA start --kubernetes
    ok "Colima restarted with Kubernetes"
else
    info "Colima is not running — starting with --kubernetes (first run takes ~2 min)"
    $COLIMA start --kubernetes
    ok "Colima started with Kubernetes"
fi
echo ""

# ── 3. Docker reachable ───────────────────────────────────────────────────────
echo "[3/4] Verifying Docker..."

$DOCKER info > /dev/null 2>&1 || fail "Docker daemon not reachable. Check: colima status"
DOCKER_VER=$($DOCKER --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
ok "Docker $DOCKER_VER reachable"

# Pre-pull postgres so it doesn't happen live during the demo
if ! $DOCKER image inspect postgres:16-alpine > /dev/null 2>&1; then
    info "Pre-pulling postgres:16-alpine (one-time, ~60 MB)..."
    $DOCKER pull postgres:16-alpine
fi
ok "postgres:16-alpine ready"
echo ""

# ── 4. Kubernetes reachable ───────────────────────────────────────────────────
echo "[4/4] Verifying Kubernetes..."

$KUBECTL cluster-info > /dev/null 2>&1 || fail "kubectl cannot reach cluster. Check: colima status"
NODE_STATUS=$($KUBECTL get nodes --no-headers 2>/dev/null | awk '{print $2}')
[[ "$NODE_STATUS" == "Ready" ]] || fail "K8s node is not Ready (status: $NODE_STATUS)"
ok "Cluster reachable — node is Ready"
echo ""

# ── Summary ───────────────────────────────────────────────────────────────────
echo "==> All checks passed. Run 'bash demo/reset.sh' to ensure a clean state, then start the demo."
