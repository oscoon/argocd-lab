# 00 · Look around

**Goal:** know what's running and how to read Argo CD's two statuses.

1. Open http://argocd.localtest.me and log in. You see seven Applications: `root`, `projects`, `argocd`, `traefik`,
   `shop-dev`, `shop-staging` and `shop-prod`.
2. Click **root**. Its children are Applications, the "app of apps". Click **shop-dev** and switch between the tree,
   network and list views (icons top right).
3. Every app shows two things that are easy to mix up:
   - **Sync status:** does the cluster match git? `Synced` or `OutOfSync`.
   - **Health:** is it working? `Healthy`, `Progressing`, `Degraded`, `Missing`, `Suspended`.

   `shop-prod` is `OutOfSync` and `Missing`: git describes it, but it was never deployed, because prod doesn't
   sync on its own. You'll fix that in lab 04.
4. Open http://shop-dev.localtest.me and http://shop-staging.localtest.me. Note the version and colour.
5. Optional CLI (`brew install argocd`, then `./lab.sh login`):

   ```bash
   argocd app list
   argocd app get shop-dev
   argocd app resources shop-dev
   ```

**At work:** "Synced but Degraded" means git was applied fine and the app is broken; "OutOfSync but Healthy" means it
works but isn't what git says. Reading those two correctly is most of day-to-day Argo CD.
