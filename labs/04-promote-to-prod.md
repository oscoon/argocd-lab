# 04 · Promote to production

**Goal:** a reviewed, manual production release.

1. Prod has never been deployed. Open **shop-prod → App diff**: everything is new. Click **Sync → Synchronize**.
   Watch the operation: the PreSync migration runs first, then the ConfigMap (wave -1), then the rest, then the
   PostSync smoke test. Open http://shop-prod.localtest.me: version 6.13.0.
2. Promote staging's version to prod. In `shop/envs/prod/kustomization.yaml` set `newTag: "6.14.0"`. Push.
3. Prod turns `OutOfSync`. Review **App diff**: only the image line changes. This is the moment a reviewer looks at
   at work.
4. Sync it, from the UI or the CLI:

   ```bash
   argocd app diff shop-prod
   argocd app sync shop-prod
   argocd app wait shop-prod --health
   ```

5. Do a full promotion chain on your own: put `6.15.0` on dev, then staging, then prod.

**At work:** this is the shape of most production pipelines: automated lower environments, and a manual sync or an
approval step (for example a change request) before prod.
