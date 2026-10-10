# 10 · Argo CD manages itself

**Goal:** change platform components, including Argo CD, through git.

1. **A Helm value.** In `apps/traefik.yaml`, set `deployment.replicas: 2`. Push and watch the **traefik** app: the
   rendered chart changes and a second pod starts. Open **App details → Parameters** to see the values Argo CD used.
2. **Argo CD's own config.** In `bootstrap/argocd/argocd-cm.yaml`, add under `data:`:

   ```yaml
   ui.bannercontent: "Lab cluster: everything here comes from git"
   ```

   Push. The **argocd** app syncs its own ConfigMap; reload the UI to see the banner.
3. **Upgrading Argo CD** is the same move: change the version in the URL in `bootstrap/argocd/kustomization.yaml` and
   push. Read the upgrade notes for the target version first, as you would at work.
4. Rebuild everything from git to prove it: `./lab.sh down && ./lab.sh up`. Your banner, replicas and environments
   all come back.

**Bonus:** connect this cluster to Syncline. Follow `integrations/argocd` in the Syncline repo (notifications secret,
ConfigMap, Application annotations); put the annotations in the ApplicationSet template so every shop environment
reports deployments to Jira.
