# Implementation Plan: dasmeta/helm (repository-level)

**Repository**: dasmeta/helm  
**Purpose**: Reference plan for the speckit workflow in this repo. Use when running `/speckit.plan` for a feature branch.

**Note**: This file describes the **repository context** for `/speckit.plan`. Per-feature plans are generated under `specs/<###-feature-name>/plan.md` from `.specify/templates/plan-template.md` and filled using this context plus the feature spec.

## How to run /speckit.clarify

**Purpose**: Resolve ambiguities and document scope/decisions for a specific chart or scope before or alongside planning.

- **Target**: Use for a chart (e.g. `dasmeta/base` = base chart) or for the whole feature (spec-level Clarifications section in `spec.md`).
- **Output (chart-specific)**: Create or update `specs/<branch>/clarifications/<chart-name>.md` (e.g. `specs/002-chart-examples-readme/clarifications/base.md`). Include: Scope (in/out), Decisions (Q&A table), Edge cases, Open questions.
- **Output (feature-level)**: Add or extend the **Clarifications** section in `specs/<branch>/spec.md` with session Q&A.
- **Next**: Proceed to `/speckit.plan` or `/speckit.tasks`; reference clarifications in plan/tasks where needed.

## Summary

dasmeta/helm is a Helm chart repository. All deliverables are charts under `charts/<chart-name>/`. The speckit workflow is: **spec** → **plan** → **tasks**. Running `/speckit.plan` on a feature branch (e.g. `002-chart-examples-readme`) creates or updates that feature’s `specs/<branch>/plan.md`, and should produce Phase 0/1 artifacts (research, data-model, quickstart, contracts) aligned with the constitution below.

## How to run /speckit.plan

1. **Branch**: Use a feature branch named `###-feature-name` (e.g. `001-spec-workflow`, `002-chart-examples-readme`).  
   Fallback: `SPECIFY_FEATURE` env or latest `specs/NNN-*` directory.
2. **Prerequisite**: `specs/<branch>/spec.md` must exist (create via `/speckit.specify`).
3. **Command**: Run `/speckit.plan` (or the agent equivalent). It should:
   - Resolve the feature branch and paths via `.specify/scripts/bash/setup-plan.sh` or equivalent.
   - Copy `.specify/templates/plan-template.md` to `specs/<branch>/plan.md` if missing.
   - **Fill** the plan from the feature spec and this repository context: Summary, Technical Context, Constitution Check, Project Structure.
   - Produce or update: `research.md`, `data-model.md`, `quickstart.md`, `contracts/` under `specs/<branch>/`.
4. **Gate**: Constitution Check must pass before Phase 0; re-check after Phase 1.
5. **Next**: Run `/speckit.tasks` to generate `specs/<branch>/tasks.md` (not created by plan).

## How to run /speckit.tasks

**Purpose**: Generate or refresh the implementation task list for the current feature from spec + plan.

- **Prerequisites**: `specs/<branch>/spec.md` and `specs/<branch>/plan.md` must exist (and ideally research.md, data-model.md, contracts/).
- **Branch**: Same as plan—feature branch `###-feature-name` or `SPECIFY_FEATURE` or latest `specs/NNN-*`.
- **Command**: Run `/speckit.tasks` (or the agent equivalent). It should:
  - Resolve the feature branch (e.g. via `.specify/scripts/bash/common.sh` / `check-prerequisites.sh`).
  - Use `.specify/templates/tasks-template.md` as structure only; **replace** sample tasks with **actual** tasks derived from:
    - User stories and acceptance scenarios in `spec.md`
    - Requirements and structure in `plan.md`
    - Entities in `data-model.md` and contracts in `contracts/`
  - Write output to `specs/<branch>/tasks.md`.
- **Path conventions (dasmeta/helm)**: Charts under `charts/<chart-name>/`; examples under `examples/<chart-name>/`; no `src/` or app code. Phases: Setup → Foundational → User Story 1 (P1) → User Story 2 (P2) → … → Polish. Use `[P]` for tasks that can run in parallel (e.g. per-chart work).
- **Next**: Implement tasks; run `/speckit.analyze` to check for CRITICAL issues; validate with `helm lint` / `helm template` per constitution.

**Example**: For branch `002-chart-examples-readme`, tasks live in `specs/002-chart-examples-readme/tasks.md` (already filled from spec/plan).

## How to run /speckit.analyze

**Purpose**: Check feature docs (spec, plan, tasks) for consistency, completeness, and constitution alignment; surface CRITICAL issues that must be fixed before or during implementation.

- **Scope**: Run over the current feature branch (e.g. `specs/002-chart-examples-readme/`) or over all feature dirs under `specs/`.
- **Inputs**: `spec.md`, `plan.md`, `tasks.md`; optionally `research.md`, `data-model.md`, `contracts/`; reference `.specify/memory/constitution.md` for gates.
- **Checks**:
  - **Spec**: User stories, acceptance scenarios, FRs, and success criteria present and unambiguous; no [NEEDS CLARIFICATION] left.
  - **Plan**: Summary and technical context align with spec; Constitution Check table present and all gates PASS or justified in Complexity Tracking; project structure matches repo (charts/, examples/, specs/).
  - **Tasks**: Every user story has implementation tasks; task IDs and phases are consistent; path conventions match plan (charts/<name>/, examples/<name>/); no sample/placeholder tasks left from template.
  - **Constitution**: Plan gates map to constitution principles; no unjustified violations.
- **Output**: Report CRITICAL (block merge / must fix), WARNING (should fix or document), OK. Write to `specs/<branch>/analysis.md` or print in run.
- **Next**: Address CRITICAL items; optionally fix WARNINGs; re-run after changes.

**Example**: `specs/002-chart-examples-readme/analysis.md` (see below or run to regenerate).

## How to run /speckit.implement

**Purpose**: Execute the task list for the current feature—implement changes in repo (charts, examples, docs) and validate per constitution and tasks.

- **Prerequisites**: `specs/<branch>/tasks.md` with tasks derived from spec + plan; analysis run with no CRITICAL issues (recommended).
- **Branch**: Feature branch `###-feature-name`; work in repo root (dasmeta/helm).
- **Command**: Run `/speckit.implement` (or the agent equivalent). It should:
  - Resolve the feature branch and open `specs/<branch>/tasks.md`.
  - Execute tasks in **phase order** (Setup → Foundational → User Story phases → Polish). Within a phase, [P] tasks can be done in parallel.
  - For each task: make the required edits (README, examples, etc.); run validation stated in the task (e.g. `helm lint`, `helm template` with example); mark task [x] when done.
  - **Validation**: After chart/example changes, run `helm lint charts/<name>` and `helm template test charts/<name> -f examples/<name>/<file>.yaml` from repo root; fix any failures.
  - **Version bump (mandatory)**: Before considering implement complete, complete the **version-bump task** (e.g. T030 in 002). Per constitution and spec FR-005: for every chart that was modified in the feature (README, examples, templates, or any file under that chart), increment `version` in `charts/<chart-name>/Chart.yaml` (at least PATCH). If a chart depends on another chart that was bumped (e.g. base depends on gateway-api), update the dependency version in the parent Chart.yaml. Do not skip this step—tasks.md MUST include an explicit version-bump task and it MUST be executed and marked [x].
- **Output**: Updated repo (charts/, examples/, specs/); tasks.md with all tasks including version-bump marked [x]; optional `specs/<branch>/implementation.md` summarizing what was done and how to re-validate.
- **Next**: Commit (per logical group or phase); run `/speckit.analyze` if tasks or spec changed; open PR.

**Path conventions (dasmeta/helm)**: Charts under `charts/<chart-name>/`; examples under `examples/<chart-name>/`; no `src/`. See tasks.md Path Conventions and quickstart.md for implementer steps.

**Example**: For 002, T001–T029 are done; T030 (version bump) MUST be executed when you run implement—then implement is complete. T026 (optional new-user test) may be run and documented. See `specs/002-chart-examples-readme/implementation.md`.

## Technical Context (repository default)

**Language/Version**: YAML (Helm templates, values), Markdown (READMEs), Helm 3  
**Primary Dependencies**: Helm 3.x, Kubernetes (version per chart in Chart.yaml / kubeVersion)  
**Storage**: N/A (charts are declarative manifests; no runtime storage)  
**Testing**: `helm lint charts/<chart-name>`, `helm template <release> charts/<chart-name> -f <values>`; CI SHOULD enforce  
**Target Platform**: Kubernetes clusters (version documented per chart)  
**Project Type**: helm-chart-repository  
**Performance Goals**: N/A (chart rendering/install are tooling concerns)  
**Constraints**: Charts under `charts/`; configuration only via values.yaml and overrides; lint/template MUST pass; version bump on any chart change (including README) per FR-005 in 002 spec  
**Scale/Scope**: Multiple top-level charts (e.g. base, base-cronjob, gateway-api, proxysql, …); each chart one directory; examples in `examples/<chart-name>/`

## Constitution Check (plan gate)

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate |
|-----------|------|
| I. Chart-First | All deliverables are Helm charts under `charts/<chart-name>/`; installable via `helm upgrade --install` or as dependency |
| II. Values Contract | Configuration only via values.yaml and `--set`/`-f`; no hardcoded env-specific values; public values documented in README/values.yaml |
| III. Lint & Template | Every chart MUST pass `helm lint` and `helm template` with default (or example) values before merge; CI SHOULD enforce |
| IV. Versioning & Compatibility | Chart and app version in Chart.yaml; semver; breaking value changes = MAJOR bump; bump version on any change (including README) per 002 contract |
| V. Simplicity & Defaults | Default values produce working install for primary use case; optional features behind explicit flags (YAGNI) |

Violations must be justified in the feature’s plan **Complexity Tracking** table.

## Project Structure

### Specs and workflow (this repo)

```text
specs/
├── 001-spec-workflow/       # Feature: speckit workflow setup
│   ├── spec.md
│   ├── plan.md
│   ├── research.md
│   ├── data-model.md
│   ├── quickstart.md
│   ├── contracts/
│   └── tasks.md
├── 002-chart-examples-readme/
│   ├── spec.md
│   ├── plan.md
│   └── ...
.specify/
├── plan.md                  # This file (repo-level plan reference)
├── memory/
│   └── constitution.md     # Single source of truth for chart principles
├── templates/
│   ├── plan-template.md    # Filled by /speckit.plan per feature
│   ├── spec-template.md
│   ├── tasks-template.md
│   └── ...
└── scripts/bash/
    ├── setup-plan.sh       # Resolves branch, copies plan template
    ├── check-prerequisites.sh
    └── ...
```

### Charts and examples

```text
charts/
├── base/
├── base-cronjob/
├── cloudwatch-agent-prometheus/
├── flagger-metrics-and-alerts/
├── gateway-api/
├── helm-chart-test/
├── kafka-connect/
├── karpenter-nodes/
├── kubernetes-event-exporter-enriched/
├── mongodb-bi-connector/
├── namespaces-and-docker-auth/
├── nfs-provisioner/
├── pgcat/
├── proxysql/
├── resource/
├── sentry-relay/
├── spqr-router/
├── weave-scope/
└── ... (other chart directories)

examples/
├── base/
├── gateway-api/
└── <chart-name>/           # One dir per top-level chart; example values YAMLs
```

**Structure decision**: Helm chart repository. No application code; deliverables are charts under `charts/`. Spec workflow lives under `specs/<branch>/` and `.specify/`. Per constitution: chart names lowercase, hyphen-separated.

## Complexity Tracking

Reserved for feature-level plans when Constitution Check has violations that are justified. Repository-level plan: no violations.
