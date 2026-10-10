# 08 · ApplicationSets

**Goal:** environments as folders.

`apps/shop.yaml` is an ApplicationSet with a git directory generator: one Application per folder in `shop/envs/`.

1. Add a QA environment:

   ```bash
   cp -r shop/envs/staging shop/envs/qa
   sed -i '' 's/staging/qa/g' shop/envs/qa/kustomization.yaml    # macOS sed
   git add shop/envs/qa && git commit -m "Add qa environment" && git push
   ```

2. Within a minute **shop-qa** appears, syncs itself into namespace `shop-qa`, and http://shop-qa.localtest.me works.
   Nobody touched Argo CD.
3. Remove the folder and push. The ApplicationSet deletes shop-qa and its resources. The `shop-qa` namespace stays:
   namespaces created with `CreateNamespace=true` are never deleted.
4. Read the `templatePatch` in `apps/shop.yaml`: it's why every environment except `prod` syncs automatically.

**At work:** this is how one manifest manages hundreds of apps, clusters or tenants. Other generators take a list,
the clusters Argo CD knows, or pull requests (preview environments).
