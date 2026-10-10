#!/usr/bin/env bash
# Argo CD lab on your Mac: a kind cluster where Argo CD runs everything from this git repo.
#
#   ./lab.sh check      verify the tools you need
#   ./lab.sh init       make this folder a git repo and push it to GitHub (Argo CD reads it from there)
#   ./lab.sh up         create the cluster and bootstrap Argo CD (about 5 minutes)
#   ./lab.sh password   print the Argo CD admin password
#   ./lab.sh login      log the argocd CLI in (brew install argocd)
#   ./lab.sh down       delete the cluster (your git repo stays)
set -euo pipefail
cd "$(dirname "$0")"

CLUSTER=argocd-lab
LAB_REPO="${LAB_REPO:-oscoon/argocd-lab}"
REPO_URL="https://github.com/$LAB_REPO.git"
say() { printf '\033[1;32m▸ %s\033[0m\n' "$*"; }
die() { printf '\033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }
kc() { kubectl --context "kind-$CLUSTER" "$@"; }

cmd_check() {
  local ok=1
  for t in docker kind kubectl git; do command -v "$t" >/dev/null && echo "  ✓ $t" || { echo "  ✗ $t"; ok=0; }; done
  for t in argocd gh; do command -v "$t" >/dev/null && echo "  ✓ $t" || echo "  · $t (optional: brew install $( [ $t = gh ] && echo gh || echo argocd ))"; done
  docker info >/dev/null 2>&1 && echo "  ✓ docker is running" || { echo "  ✗ docker is not running"; ok=0; }
  [ "$ok" = 1 ] || die "Install what's missing: brew install kind kubectl"
  say "All set."
}

cmd_init() {
  if [ "$LAB_REPO" != "oscoon/argocd-lab" ]; then
    say "Pointing manifests at $REPO_URL"
    grep -rl "https://github.com/oscoon/argocd-lab.git" apps projects bootstrap | xargs perl -pi -e "s#https://github.com/oscoon/argocd-lab.git#$REPO_URL#g"
  fi
  [ -d .git ] || { git init -q -b main; git add -A; git commit -qm "Argo CD lab"; }
  if git remote get-url origin >/dev/null 2>&1; then say "Remote already set: $(git remote get-url origin)"; return; fi
  if command -v gh >/dev/null; then
    gh repo create "$LAB_REPO" --public --source . --push
  else
    printf '\033[1;33m! Create the GitHub repo yourself:\033[0m\n'
    echo "  1. Create an EMPTY public repo at https://github.com/new named ${LAB_REPO#*/}"
    echo "  2. In this folder: git remote add origin git@github.com:$LAB_REPO.git && git push -u origin main"
  fi
}

cmd_up() {
  git remote get-url origin >/dev/null 2>&1 || die "Run ./lab.sh init first (Argo CD needs this repo on GitHub)."
  [ -z "$(git status --porcelain)" ] || say "Note: you have uncommitted changes. Argo CD only sees what you push."
  kind get clusters 2>/dev/null | grep -qx "$CLUSTER" || { say "Creating cluster"; kind create cluster --config kind.yaml --wait 120s; }

  say "Installing Argo CD (bootstrap/argocd)"
  kc create namespace argocd --dry-run=client -o yaml | kc apply -f - >/dev/null
  kc apply -k bootstrap/argocd --server-side --force-conflicts >/dev/null
  kc -n argocd rollout status deploy/argocd-server deploy/argocd-repo-server deploy/argocd-applicationset-controller --timeout=300s
  kc -n argocd rollout status statefulset/argocd-application-controller --timeout=300s

  say "Handing over to git: applying the root app"
  kc apply -f bootstrap/root-app.yaml >/dev/null
  say "Waiting for Traefik so the URLs work (Argo CD is installing it from apps/traefik.yaml)"
  for _ in $(seq 1 60); do
    kc -n traefik get deploy traefik >/dev/null 2>&1 && kc -n traefik rollout status deploy/traefik --timeout=10s >/dev/null 2>&1 && break
    sleep 5
  done
  echo
  say "Ready."
  echo "  Argo CD:  http://argocd.localtest.me   user admin, password: $(cmd_password)"
  echo "  Shop:     http://shop-dev.localtest.me   http://shop-staging.localtest.me   http://shop-prod.localtest.me"
  echo "            (prod syncs manually: it stays OutOfSync until you sync it, see labs/04)"
  echo "  Labs:     labs/README.md"
}

cmd_password() { kc -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo; }
cmd_login() { argocd login argocd.localtest.me --grpc-web --plaintext --username admin --password "$(cmd_password)"; }
cmd_down() { kind delete cluster --name "$CLUSTER"; }

case "${1:-}" in
  check|init|up|password|login|down) c="$1"; shift; "cmd_$c" "$@" ;;
  *) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
