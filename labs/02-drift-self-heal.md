# 02 · Drift and self-heal

**Goal:** see what Argo CD does about changes that bypass git.

1. Scale dev by hand and watch it come back:

   ```bash
   k -n shop-dev scale deploy/shop --replicas=1
   k -n shop-dev get deploy shop -w     # back to 3 within seconds
   ```

   `selfHeal: true` (in `apps/shop.yaml`) makes Argo CD undo drift as soon as it sees it.
2. Delete the whole Deployment: `k -n shop-dev delete deploy shop`. It's recreated.
3. Now prod, which has no automated sync. Scale it (after lab 04 has deployed it): `k -n shop-prod scale deploy/shop
   --replicas=5`. Prod turns `OutOfSync`; open **App diff** to see exactly what differs. Nothing is reverted until
   someone syncs.
4. Try turning off auto-sync for shop-dev in the UI (**App details → Disable auto-sync**). A few seconds later it's
   back on: the ApplicationSet owns that Application and rewrites it from its template. Change `apps/shop.yaml` instead.

**At work:** if a hotfix with kubectl "doesn't stick", this is why. Either fix it in git, or know that prod-style apps
will show the drift until the next sync overwrites it.
