# Prerequisites

All tools below must be installed and available on `$PATH` before running any demo step.

## Required Tools

| Tool | Minimum version | Verify |
|------|----------------|--------|
| Docker Engine | 26.x | `docker --version` |
| Docker Compose plugin | 2.x | `docker compose version` |
| minikube | 1.33+ | `minikube version` |
| kubectl | 1.30+ | `kubectl version --client` |
| Python | 3.12+ | `python3 --version` |
| curl | any | `curl --version` |

## Installation

### Docker Engine + Compose plugin
- **macOS / Windows**: [Docker Desktop](https://docs.docker.com/desktop/) includes both Engine and the Compose plugin.
- **Linux**: [Install Docker Engine](https://docs.docker.com/engine/install/) then [install the Compose plugin](https://docs.docker.com/compose/install/linux/).

### minikube
```bash
# macOS (Homebrew)
brew install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```
Full guide: <https://minikube.sigs.k8s.io/docs/start/>

### kubectl
```bash
# macOS (Homebrew)
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/kubectl
```
Full guide: <https://kubernetes.io/docs/tasks/tools/>

### Python 3.12+
- **macOS**: `brew install python@3.12`
- **Linux**: use your distribution's package manager or [pyenv](https://github.com/pyenv/pyenv).
- **Windows WSL2**: `sudo apt install python3.12`

## Pre-session Checklist

Run these commands before the session to confirm everything is ready:

```bash
docker --version          # Docker version 26.x or later
docker compose version    # Docker Compose version v2.x or later
minikube version          # minikube version: v1.33 or later
kubectl version --client  # Client Version: v1.30 or later
python3 --version         # Python 3.12.x or later
curl --version            # any version
```

Start minikube once so the initial image pull doesn't happen live:

```bash
minikube start
minikube status           # should show: host, kubelet, apiserver — Running
```
