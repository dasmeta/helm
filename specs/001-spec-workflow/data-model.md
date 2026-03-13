# Data Model: Spec Workflow / Helm Chart Repository

**Feature**: 001-spec-workflow  
**Date**: 2026-03-09

This repository does not have a traditional application data model. The following describe the structural and configuration “entities” relevant to the spec workflow and chart consumption.

## Chart (per chart directory)

| Attribute | Description | Validation |
|-----------|-------------|------------|
| name | Chart name (Chart.yaml `name`) | Lowercase, hyphen-separated; must match directory name |
| version | Chart semver (Chart.yaml `version`) | MAJOR.MINOR.PATCH |
| appVersion | Application version (Chart.yaml `appVersion`) | Any string; often quoted |
| type | `application` or `library` | Required in Chart.yaml |
| dependencies | List of chart dependencies | Optional; version and repository required when present |
| kubeVersion | Minimum Kubernetes version (if set) | Semver range (e.g. ">=1.21") |

## Values (per chart)

| Concept | Description |
|---------|-------------|
| Public values | All user-configurable options MUST be in `values.yaml` and documented (README or comments). |
| Defaults | Must produce a working install for the primary use case (constitution V). |
| Optional features | Behind explicit keys (e.g. `featureX.enabled: false`). |
| No hardcoding | No cluster names, tenant IDs, or env-specific secrets in templates. |

## Spec Workflow Artifacts

| Entity | Location | Purpose |
|--------|----------|---------|
| spec | specs/<###-feature-name>/spec.md | User stories, requirements, success criteria |
| plan | specs/<###-feature-name>/plan.md | Technical context, Constitution Check, project structure |
| research | specs/<###-feature-name>/research.md | Decisions and rationale |
| tasks | specs/<###-feature-name>/tasks.md | Implementation task list (from /speckit.tasks) |

No state machines or lifecycle transitions—charts are declarative; workflow artifacts are static docs.
