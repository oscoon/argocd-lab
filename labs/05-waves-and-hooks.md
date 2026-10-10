# 05 · Sync waves and hooks

**Goal:** control the order of a sync, and see a failing step stop a release.

Look at `shop/base/`: `config.yaml` has `sync-wave: "-1"` (created before wave 0), `migrate-job.yaml` is a `PreSync`
hook and `smoke-test-job.yaml` a `PostSync` hook. The order is: PreSync hooks → wave -1 → wave 0 → … → PostSync hooks.

1. Break the migration and release a new version to dev in the same commit:
   - In `shop/base/migrate-job.yaml`, change the command to `["sh", "-c", "echo 'migration failed'; exit 1"]`.
   - In `shop/envs/dev/kustomization.yaml`, set `newTag: "6.15.0"`.
   - Push.
2. shop-dev's sync fails at the PreSync hook. Open the failed Job's logs from the tree. The Deployment was never
   touched: dev still runs the old version. staging fails the same way (the base is shared); prod isn't affected until
   someone syncs it.
3. Fix the command and push. A new commit means a new sync attempt: the migration passes and 6.15.0 rolls out.
4. Why didn't Argo CD retry the failed sync by itself? Automated sync tries each commit once. Look up `syncPolicy.retry`
   and add it to the template in `apps/shop.yaml` if you want retries.

**At work:** database migrations as PreSync hooks are common; this is exactly how a bad migration blocks a release
instead of half-deploying it.
