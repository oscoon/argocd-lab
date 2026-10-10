# Labs

| # | Lab | You learn |
|---|---|---|
| 00 | [Look around](00-look-around.md) | Applications, the resource tree, sync and health status, the CLI |
| 01 | [The GitOps loop](01-gitops-loop.md) | Git is the only way in: change, push, watch it roll out |
| 02 | [Drift and self-heal](02-drift-self-heal.md) | What happens when someone uses kubectl |
| 03 | [Pruning](03-pruning.md) | Deleting from git deletes from the cluster |
| 04 | [Promote to production](04-promote-to-prod.md) | Manual sync, diffs, promotion between environments |
| 05 | [Waves and hooks](05-waves-and-hooks.md) | Ordering a sync; a failing migration stops a release |
| 06 | [A broken release](06-broken-release.md) | Health states, Degraded vs Progressing, fixing forward |
| 07 | [Rollback](07-rollback.md) | Argo CD rollback vs git revert, and why automated apps refuse rollbacks |
| 08 | [ApplicationSets](08-applicationsets.md) | A new environment is a new folder |
| 09 | [Guardrails](09-guardrails.md) | What AppProjects stop a team from doing |
| 10 | [Argo CD manages itself](10-self-management.md) | Changing Helm values and Argo CD's own config through git |

Conventions: run commands from the repo root. `k` below means `kubectl --context kind-argocd-lab`
(`alias k='kubectl --context kind-argocd-lab'`). Argo CD checks git every 60 seconds; click **Refresh** on an app to
make it look immediately.
