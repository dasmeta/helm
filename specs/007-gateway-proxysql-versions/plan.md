# Base Chart Gateway-API and ProxySQL Version Updates — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the base chart’s gateway-api dependency to 0.1.3 (and refresh dependency artifacts), and set the proxysql chart’s app version to 3.0.6, with version bumps and validation.

**Architecture:** Two independent chart updates: (1) base chart — change dependency version in Chart.yaml and run `helm dependency update` from the base chart directory so Chart.lock and charts/base/charts reflect 0.1.3; (2) proxysql chart — set appVersion to 3.0.6 in Chart.yaml. Both charts get a PATCH version bump; lint and template validate installability.

**Tech Stack:** Helm 3, YAML (Chart.yaml, Chart.lock, values). No new dependencies.

---

## Implementation Plan: 007-gateway-proxysql-versions

**Branch**: `007-gateway-proxysql-versions` | **Date**: 2025-03-13 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `specs/007-gateway-proxysql-versions/spec.md`

## Summary

- **P1:** Base chart MUST declare gateway-api at version 0.1.3 and have dependency metadata updated (run `helm dependency update` in the base chart context so `charts/base/charts` and Chart.lock reflect 0.1.3).
- **P2:** ProxySQL chart MUST declare app version 3.0.6.
- Version bumps (PATCH) for both modified charts; lint and template must pass (constitution).

## Technical Context

**Language/Version**: YAML (Helm Chart.yaml, values), Helm 3  
**Primary Dependencies**: Helm 3.x, Kubernetes (per chart)  
**Storage**: N/A  
**Testing**: `helm lint charts/<name>`, `helm template <release> charts/<name> -f <values>`  
**Target Platform**: Kubernetes  
**Project Type**: helm-chart-repository  
**Constraints**: Charts under `charts/`; version bump on any chart change; lint/template MUST pass (constitution III, IV).  
**Scale/Scope**: Two charts touched — base, proxysql.

## Constitution Check

*GATE: Must pass before Phase 0. Re-check after implementation.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Chart-First | Deliverables are Helm charts under `charts/`; installable via helm | OK — no new charts |
| II. Values Contract | Config only via values; no hardcoded env-specific values | OK — no value changes |
| III. Lint & Template | Every chart MUST pass `helm lint` and `helm template` | Run for base and proxysql |
| IV. Versioning & Compatibility | Chart version + app version in Chart.yaml; bump on change | Bump base and proxysql PATCH |
| V. Simplicity & Defaults | Defaults produce working install | OK — version-only change |
| Example testing & regression | New/updated examples tested; existing examples re-run | N/A — no example changes |
| Official documentation | Check upstream docs for object/resource fields | N/A — version metadata only |

No violations; Complexity Tracking left empty.

## Project Structure

### Documentation (this feature)

```text
specs/007-gateway-proxysql-versions/
├── plan.md              # This file
├── spec.md
├── checklists/
│   └── requirements.md
└── (optional: research.md, quickstart.md — not required for this scope)
```

### Source (repository root)

```text
charts/
├── base/
│   ├── Chart.yaml       # Modify: gateway-api version 0.1.2 → 0.1.3; then version bump
│   ├── Chart.lock       # Updated by: helm dependency update
│   └── charts/          # Updated by: helm dependency update (gateway-api tgz)
└── proxysql/
    └── Chart.yaml       # Modify: appVersion 3.0.5 → 3.0.6; then version bump
```

**Structure decision:** Only existing chart files are modified; no new charts or examples.

## Complexity Tracking

None. All constitution gates pass.

---

## Implementation Tasks

### Task 1: Base chart — set gateway-api dependency to 0.1.3

**Files:**
- Modify: `charts/base/Chart.yaml` (dependencies section)

- [ ] **Step 1.1: Update gateway-api version in Chart.yaml**

In `charts/base/Chart.yaml`, under `dependencies`, change the gateway-api entry from `version: 0.1.2` to `version: 0.1.3`. Leave name, repository, alias, and condition unchanged.

- [ ] **Step 1.2: Run helm dependency update for base chart**

From repo root:

```bash
cd /Users/tmuradyan/projects/dasmeta/helm && helm dependency update charts/base
```

Expected: Chart.lock and `charts/base/charts/` updated; lock shows gateway-api version 0.1.3. If the repo is unreachable, the command will fail (acceptable per spec edge case).

- [ ] **Step 1.3: Bump base chart version (PATCH)**

In `charts/base/Chart.yaml`, increment `version` (e.g. 0.3.23 → 0.3.24). Optionally set `appVersion` to the same as `version` for consistency, or leave appVersion as-is if the base chart does not track an “app” version separately.

- [ ] **Step 1.4: Validate base chart**

From repo root:

```bash
helm lint charts/base
helm template test-base charts/base
```

Expected: lint and template both succeed.

- [ ] **Step 1.5: Commit base chart changes**

```bash
git add charts/base/Chart.yaml charts/base/Chart.lock charts/base/charts/
git commit -m "chore(base): bump gateway-api dependency to 0.1.3 and chart version"
```

---

### Task 2: ProxySQL chart — set app version to 3.0.6

**Files:**
- Modify: `charts/proxysql/Chart.yaml`

- [ ] **Step 2.1: Update appVersion in Chart.yaml**

In `charts/proxysql/Chart.yaml`, set `appVersion: "3.0.6"` (replace "3.0.5").

- [ ] **Step 2.2: Bump proxysql chart version (PATCH)**

In `charts/proxysql/Chart.yaml`, increment `version` (e.g. 1.2.2 → 1.2.3).

- [ ] **Step 2.3: Validate proxysql chart**

From repo root:

```bash
helm lint charts/proxysql
helm template test-proxysql charts/proxysql
```

Expected: both pass. If examples exist, run template with an example values file to confirm no regression.

- [ ] **Step 2.4: Commit proxysql chart changes**

```bash
git add charts/proxysql/Chart.yaml
git commit -m "chore(proxysql): set appVersion to 3.0.6 and bump chart version"
```

---

### Task 3: Final validation and handoff

- [ ] **Step 3.1: Re-run lint and template for both charts**

From repo root:

```bash
helm lint charts/base charts/proxysql
helm template test-base charts/base
helm template test-proxysql charts/proxysql
```

Expected: all succeed.

- [ ] **Step 3.2: Confirm success criteria**

- SC-001: Base chart declares gateway-api 0.1.3 and dependency update has been run (Chart.lock and charts/base/charts show 0.1.3).
- SC-002: ProxySQL chart shows appVersion 3.0.6.
- SC-003: `helm dependency update charts/base` completed successfully with 0.1.3.
- SC-004: Lint and template pass for both charts (no regressions).

Plan complete. Next: run `/speckit.tasks` to generate `specs/007-gateway-proxysql-versions/tasks.md` for formal task tracking, or implement directly using the steps above.
