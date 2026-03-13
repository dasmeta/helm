<!--
  Sync Impact Report
  Version: 1.5.0 → 1.6.0 (MINOR: new material guidance)
  Modified principles: None
  Added sections: Development Workflow — App version and image tag sync (when updating app version, also update image tag in values.yaml so Chart.yaml appVersion and default image tag match).
  Removed sections: None
  Templates: .specify/templates/plan-template.md ✅ (Constitution Check remains derived from constitution)
             .specify/templates/spec-template.md ✅ (no mandatory sections added/removed)
             .specify/templates/tasks-template.md ✅ (no change)
  Commands: .specify/templates/commands/ not present; N/A
  Follow-up TODOs: None
-->

# Dasmeta Helm Charts Constitution

## Core Principles

### I. Chart-First

Every deliverable that deploys or configures software on Kubernetes MUST be packaged as a Helm chart. Charts live under `charts/<chart-name>/`. One chart per directory; each chart MUST have a clear, single purpose. Charts MUST be self-contained and installable via `helm upgrade --install` (or as a dependency). Rationale: Consistent packaging and discovery; the repo is the single source of truth for Dasmeta Helm charts.

### II. Values Contract

Configuration MUST be exposed only via `values.yaml` and `--set` / `-f` overrides. Templates MUST NOT hardcode environment-specific values (e.g., cluster names, tenant IDs). All public values MUST be documented in the chart README and/or comments in `values.yaml`. Rationale: Reproducibility and safe reuse across environments.

### III. Lint & Template (NON-NEGOTIABLE)

Every chart MUST pass `helm lint` and `helm template` (or equivalent) with default values before merge. When creating or editing a chart, the implementer MUST run `helm lint` for the affected chart(s) and `helm template` with default or relevant example values before considering the change complete. CI SHOULD enforce these checks. Rationale: Catches invalid YAML and template errors before release; prevents broken charts from being published.

### IV. Versioning & Compatibility

Chart versions MUST follow semantic versioning (MAJOR.MINOR.PATCH). Chart version and app version MUST be set in `Chart.yaml`. Breaking changes to values or rendered manifests require a MAJOR bump and SHOULD include migration notes in the chart README or release notes. Document supported Kubernetes and Helm versions in chart README or `Chart.yaml` (e.g., kubeVersion). Rationale: Safe upgrades and clear compatibility expectations.

### V. Simplicity & Defaults

Default values MUST produce a working install for the primary use case. Optional features SHOULD be behind explicit flags in values. Avoid optional dependencies or toggles that make the default path complex or fragile (YAGNI). Rationale: New users get a working experience out of the box; complexity is opt-in.

## Additional Constraints

- **Repository layout**: All charts live under `charts/` at repository root. Naming: lowercase, hyphen-separated (e.g., `base-cronjob`, `karpenter-nodes`).
- **Helm/Kubernetes**: Document minimum Helm and Kubernetes versions per chart where they matter; prefer Helm 3 and a stated Kubernetes minor version (e.g., 1.18+).
- **Publishing**: Charts are published to the Dasmeta Helm repo; installation is via `helm repo add dasmeta https://dasmeta.github.io/helm`.
- **Example files**: Every new or edited file under `examples/<chart-name>/*.yaml` MUST have at the top a comment line with the runnable command to use that example, e.g. `# helm diff upgrade --install -n <namespace> <release> ./charts/<chart-name>/ -f ./examples/<chart-name>/<file>.yaml` (from repo root). This makes it obvious how to run or diff the example without reading the README.
- **README values table and sync with values.yaml**: Each chart README MUST include a table of key public values with columns: **Key**, **Description**, **Default / Example** (or equivalent). The table documents the main options from `values.yaml` so consumers can scan options without opening the file. The README table and `values.yaml` MUST be kept in sync: when values are added, removed, or changed in `values.yaml`, the README table MUST be updated in the same change (or the same PR). Rationale: single place to scan options; avoids drift between values and docs.
- **Examples for new abilities**: Whenever a change introduces new public configuration surface or behavior for consumers (e.g. a new top-level or major nested value, support for a new CRD/template, or a new usage mode of the chart), at least one example values file MUST be added or updated under `examples/<chart-name>/` to demonstrate that ability. Rationale: every major new ability is paired with a concrete, runnable example.
- **Example testing and regression**: When an example values file is added or updated under `examples/<chart-name>/`, the implementer MUST test it (e.g. `helm template <release> ./charts/<chart-name> -f ./examples/<chart-name>/<file>.yaml` from repo root). The implementer MUST also run other existing examples for that chart to check for regression. Rationale: new examples must work; changes must not break existing examples.
- **Official documentation before implementation**: Before implementing features that define or change Kubernetes object or resource fields (e.g. CRD manifests, Gateway API resources, standard K8s resources), the implementer MUST check the official latest documentation—or the documentation that corresponds to the chart's app version—for supported fields, structure, and type usage. Rationale: ensures manifests and templates align with upstream API; avoids invalid or deprecated field usage.

## Development Workflow

- **Feature/spec numbering (exact order)**: Feature branches and `specs/` directories MUST use the next available number in strict order. The format is `NNN-<short-name>` (e.g. `007-gateway-proxysql-versions`). The next number is derived from existing `specs/NNN-*` directories and from branches matching that pattern; numbers MUST NOT be reused. When creating a new feature (e.g. via `/speckit.specify` or equivalent), the workflow MUST use this next number unless a documented exception applies. Rationale: avoids duplicate prefixes, preserves chronological order, and keeps branch/spec identity unambiguous.
- **Pre-commit**: Developers SHOULD enable local git pre-commit hooks (`git config --global core.hooksPath ./githooks`) as documented in the repo README.
- **Review**: PRs SHOULD verify that the Constitution Check (plan phase) and lint/template gates are satisfied.
- **Version bumps**: When changing a chart, bump its version in `Chart.yaml` according to semver; document breaking changes.
- **App version and image tag sync**: When updating an application version in a Helm chart (e.g. `appVersion` in `Chart.yaml`), the implementer MUST also check and update any corresponding image version in `values.yaml` (e.g. `proxysql.image.tag`, or the chart’s image tag key). Both `Chart.yaml` appVersion and the default image tag in values MUST reflect the same release so that default installs use the declared app version. Rationale: avoids mismatch where Chart.yaml advertises one version but rendered manifests pull a different image tag.
- **Implement phase (speckit)**: When running the implement phase (e.g. `/speckit.implement`), the workflow MUST include a version-bump step: for every chart that was modified (README, values, templates, or any file under that chart), increment the `version` field in `charts/<chart-name>/Chart.yaml` (at least PATCH). Implement is not complete until this step is done. Feature task lists (e.g. `tasks.md`) MUST contain an explicit version-bump task (e.g. T030) so it is not forgotten.
- **Validation on chart changes**: When creating or editing a chart, run `helm lint` for the affected chart(s); run `helm template` with default values and with any new or modified example files; run `helm template` with other existing examples for the same chart to check for regression.

## Governance

This constitution supersedes ad-hoc practices for chart development within this repository. Amendments require documentation of the change, version bump of the constitution (semver: MAJOR for incompatible principle removals/redefinitions, MINOR for new principles or material guidance, PATCH for clarifications/typos), and update of the "Last Amended" date. All PRs and reviews MUST verify compliance with Core Principles; exceptions MUST be justified (e.g., in plan Complexity Tracking). Complexity beyond the principles above MUST be justified and documented.

**Version**: 1.6.0 | **Ratified**: 2026-03-09 | **Last Amended**: 2025-03-13
