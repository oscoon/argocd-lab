# 06 · A broken release

**Goal:** recognise a bad rollout and fix it forward.

1. Set dev's tag to one that doesn't exist, `newTag: "6.99.0"`, and push.
2. shop-dev becomes `Synced` but `Progressing`: git was applied, but the new pod can't pull its image
   (`ImagePullBackOff`, click the pod). The old pods keep serving, so the site still works. After the Deployment's
   progress deadline (10 minutes) it turns `Degraded`.
3. The sync operation itself keeps running: Argo CD waits for the app to be healthy before running PostSync hooks.
   Fix forward: set a real tag and push. If the old operation is still running, the new commit waits for it. Open
   **Sync status → Terminate** and Argo CD picks up the fix.

**At work:** "Synced + Progressing for a long time" almost always means pods can't start: image, config or resources.
The tree view's pod events are the fastest place to look.
