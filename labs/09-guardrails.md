# 09 · Guardrails with AppProjects

**Goal:** see what `projects/team-shop.yaml` prevents.

1. The shop team tries to add cluster-wide permissions. Create `shop/base/clusterrole.yaml`:

   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRole
   metadata:
     name: shop-reader
   rules:
     - apiGroups: [""]
       resources: [pods]
       verbs: [get, list]
   ```

   Add it to `shop/base/kustomization.yaml` and push. The shop apps report that ClusterRole isn't permitted in project
   `team-shop`.
2. Instead, try to deploy into someone else's namespace: remove the ClusterRole and add `namespace: kube-system` to the
   metadata of `shop/base/service.yaml`. Push. Also refused: the project only allows `shop-*`.
3. Undo both changes and push.
4. Compare with `projects/platform.yaml`, which allows everything. Also look at **Settings → Projects** in the UI.

**At work:** projects are how one Argo CD serves many teams safely. RBAC (who may sync which project) is configured in
`argocd-rbac-cm`, the next step if you want to go further.
