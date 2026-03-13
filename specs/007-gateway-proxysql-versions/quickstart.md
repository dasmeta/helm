# Quickstart: 007-gateway-proxysql-versions

**Goal:** Update base chart gateway-api dependency to 0.1.3 and proxysql app version to 3.0.6.

## Prerequisites

- Helm 3 installed
- Repo root: `dasmeta/helm` (e.g. `/Users/tmuradyan/projects/dasmeta/helm`)
- On branch `007-gateway-proxysql-versions`

## Steps (from repo root)

1. **Base chart**
   - Edit `charts/base/Chart.yaml`: set gateway-api dependency `version` to `0.1.3`.
   - Run: `helm dependency update charts/base`.
   - Bump base `version` (e.g. 0.3.23 → 0.3.24).
   - Run: `helm lint charts/base` and `helm template test-base charts/base`.

2. **ProxySQL chart**
   - Edit `charts/proxysql/Chart.yaml`: set `appVersion: "3.0.6"`, bump `version` (e.g. 1.2.2 → 1.2.3).
   - Run: `helm lint charts/proxysql` and `helm template test-proxysql charts/proxysql`.

3. **Commit** each chart’s changes (or one commit for both).

Full task breakdown: [plan.md](./plan.md).
