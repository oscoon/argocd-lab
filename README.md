# Argo CD lab

A small but realistic GitOps setup on your Mac, laid out the way platform teams run Argo CD in production:

- **Argo CD manages itself.** After a one-time bootstrap, its own installation lives in git (`bootstrap/argocd`).
- **App of apps.** One `root` Application points at `apps/`; everything else is created from there.
- **Projects as guardrails.** `platform` may do anything; `team-shop` may only deploy its own repo into `shop-*` namespaces.
- **A Helm chart from a chart repo** (Traefik, the ingress controller) with values kept in git.
- **An ApplicationSet** that turns every folder in `shop/envs/` into an Application. Dev and staging sync automatically, prod waits for a human.
- **Sync waves and hooks:** a config that must exist first, a database migration before every sync, a smoke test after.

```
GitHub: oscoon/argocd-lab ─────────────── Argo CD (in the cluster) polls every 60 s
   │                                        │
   bootstrap/root-app.yaml ── applied once ─┤ root ──► apps/
                                            │           ├─ projects    (wave -1) ► projects/
                                            │           ├─ argocd                ► bootstrap/argocd (itself)
                                            │           ├─ traefik               ► Helm chart traefik 41.6.0
                                            │           └─ shop (ApplicationSet) ► shop/envs/dev | staging | prod
Your Mac ── http://*.localtest.me:80 ── kind node :30080 ── Traefik ── Ingresses
```

## Start

You need Docker running and `brew install kind kubectl` (optionally `argocd` and `gh`). Port 80 on your Mac must be free.

```bash
cd ~/Projects/argocd-lab
./lab.sh check
./lab.sh init     # creates the public GitHub repo oscoon/argocd-lab and pushes this folder
./lab.sh up       # ~5 minutes
```

Then open **http://argocd.localtest.me** (user `admin`, password from `./lab.sh password`). `*.localtest.me` is a public
DNS name that points at 127.0.0.1, so nothing needs editing on your Mac.

## Labs

Work through [`labs/`](labs/README.md) in order; each takes 5–15 minutes. Every change is a git commit and push, just
like at work. `./lab.sh down` deletes the cluster; `./lab.sh up` rebuilds it from git in minutes, which is the point of
GitOps.

## Layout

| Path | What |
|---|---|
| `bootstrap/argocd/` | Argo CD install (pinned upstream manifest v3.4.10) plus this lab's config and Ingress |
| `bootstrap/root-app.yaml` | The root Application, the only thing applied with kubectl |
| `apps/` | Applications and the ApplicationSet that root creates |
| `projects/` | AppProjects |
| `shop/base/` | The shop app (podinfo): Deployment, Service, Ingress, config, hooks |
| `shop/envs/<env>/` | Kustomize overlays: image tag, replicas, colour, hostname per environment |
| `kind.yaml`, `lab.sh` | The local cluster and the helper script |
