# Quickstart: 008-proxysql-deps-image-tag

**Goal:** Update proxysql chart’s base and base-cronjob dependencies to latest from the Helm repo and set default image tag to 3.0.6.

## Prerequisites

- Helm 3 installed
- Repo root: dasmeta/helm (e.g. `/Users/tmuradyan/projects/dasmeta/helm`)
- On branch `008-proxysql-deps-image-tag`

## Steps (from repo root)

1. **Resolve dependency versions**  
   Use this repo’s `charts/base/Chart.yaml` and `charts/base-cronjob/Chart.yaml` for current version numbers (or run `helm repo update` and inspect the dasmeta repo index).

2. **Update Chart.yaml**  
   In `charts/proxysql/Chart.yaml`: set `dependencies[].version` for base and base-cronjob to the chosen versions; increment `version` (e.g. 1.2.3 → 1.2.4).

3. **Update values.yaml**  
   In `charts/proxysql/values.yaml`: set `proxysql.image.tag` to `3.0.6`.

4. **Refresh dependencies**  
   Run: `helm dependency update charts/proxysql`

5. **Validate**  
   Run: `helm lint charts/proxysql` and `helm template test-proxysql charts/proxysql`  
   Optionally run with an example: `helm template test-proxysql charts/proxysql -f examples/proxysql/<example>.yaml`

Full task breakdown: [plan.md](./plan.md). Task list: run `/speckit.tasks` to generate `tasks.md`.
