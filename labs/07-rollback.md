# 07 · Rollback

**Goal:** know both kinds of rollback and when each works.

1. On **shop-prod**, open **History and rollback**, pick the previous release and choose **Rollback**. Prod goes back
   to the older version within seconds.
2. Notice prod is now `OutOfSync`: git still says the newer version. A rollback in Argo CD is a temporary override,
   and the next sync would bring the new version back.
3. Make it permanent the GitOps way: `git revert` the promotion commit (or set the old tag) and push. Prod is `Synced`
   again.
4. Try the same rollback on **shop-dev**. Argo CD refuses: you can't roll back an app with automated sync, because the
   next reconcile would undo it. For automated apps, `git revert` is the only rollback.

**At work:** in an incident, an Argo CD rollback is the fastest button for manual apps; follow it with a revert in git
so the two agree again.
