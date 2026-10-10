# 03 · Pruning

**Goal:** removing something from git removes it from the cluster (or doesn't, and why).

1. Add a resource to dev only. Create `shop/envs/dev/feature-flags.yaml`:

   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: feature-flags
   data:
     new-checkout: "true"
   ```

   and add `- feature-flags.yaml` under `resources:` in `shop/envs/dev/kustomization.yaml`. Push. It appears.
2. Remove both lines again and push. With `prune: true`, Argo CD deletes the ConfigMap.
3. Compare with an app without pruning: `apps/argocd.yaml` has `prune: false`, so resources removed from
   `bootstrap/argocd` would be marked "requires pruning" in the UI instead of being deleted.
4. Try `k -n shop-dev create configmap stray --from-literal=a=b`. Argo CD doesn't delete it: it only manages what's in
   git. The team-shop project has `orphanedResources.warn`, so the app shows a warning for it. Delete it yourself.

**At work:** prune is why "I removed it from the repo" is enough. It's also why platform-critical apps often disable it.
