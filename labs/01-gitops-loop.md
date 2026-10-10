# 01 · The GitOps loop

**Goal:** change the cluster the only way GitOps allows: through git.

1. In `shop/envs/dev/kustomization.yaml`, change `count: 1` to `count: 3` and the message to `Shop (dev) v2`.
2. Commit and push:

   ```bash
   git commit -am "dev: 3 replicas" && git push
   ```

3. In the UI, open **shop-dev** and click **Refresh** (or wait up to a minute). Watch it go `OutOfSync`, then sync
   automatically: new pods appear in the tree and the ConfigMap changes.
4. Reload http://shop-dev.localtest.me: new message. Did the pods restart for the ConfigMap change? Look at the pod
   ages. (They didn't: a ConfigMap change alone doesn't restart pods. Real setups use kustomize's configMapGenerator,
   which adds a hash to the name so pods roll. Try it as an extra.)
5. Click **History and rollback** on shop-dev: each sync is recorded with its git commit.

**At work:** when someone asks "what's deployed?", the answer is a commit in git, and Argo CD's history tells you
when it was applied.
