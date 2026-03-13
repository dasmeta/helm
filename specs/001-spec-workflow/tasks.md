# Tasks: Spec Workflow

**Input**: Design documents from `/specs/001-spec-workflow/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Not requested in feature specification.

**Organization**: Tasks are grouped by user story. Paths follow plan.md: repository root = dasmeta/helm; charts under `charts/`; spec artifacts under `specs/001-spec-workflow/`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1 = User Story 1 (Spec-driven workflow available)
- Include exact file paths in descriptions

## Path Conventions

- **This repo**: `charts/<chart-name>/` for Helm charts; `specs/001-spec-workflow/` for this feature's docs; `.specify/` for workflow config and templates.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Ensure spec workflow structure and repo conventions are in place

- [x] T001 Verify feature branch and specs directory exist: branch `001-spec-workflow`, directory `specs/001-spec-workflow/` with spec.md and plan.md
- [x] T002 [P] Verify `.specify/` contains `memory/constitution.md`, `templates/` (plan, spec, tasks, constitution), and `scripts/bash/` (check-prerequisites.sh, setup-plan.sh, update-agent-context.sh)
- [x] T003 [P] If present, document or verify `githooks/` for pre-commit (README: `git config --global core.hooksPath ./githooks`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Constitution alignment and chart validation baseline so workflow and charts are trusted

**⚠️ CRITICAL**: User story validation depends on plan and charts being constitution-compliant

- [x] T004 Verify plan.md Constitution Check section lists all five principles (Chart-First, Values Contract, Lint & Template, Versioning, Simplicity) with PASS and no violations in `specs/001-spec-workflow/plan.md`
- [x] T005 [P] Run `helm lint charts/base` and `helm template test charts/base` from repo root; fix any failures or document known exceptions
- [x] T006 Confirm Phase 0/1 artifacts exist: `specs/001-spec-workflow/research.md`, `data-model.md`, `quickstart.md`, `contracts/chart-consumption.md`

**Checkpoint**: Foundation ready—workflow artifacts and at least one chart pass constitution gates

---

## Phase 3: User Story 1 - Spec-driven workflow available (Priority: P1) 🎯 MVP

**Goal**: Dasmeta/helm uses speckit workflow (spec → plan → tasks); new charts and changes are specified and validated against the constitution.

**Independent Test**: Run `/speckit.analyze` after tasks.md exists; no CRITICAL issues.

### Implementation for User Story 1

- [x] T007 [US1] Confirm spec.md contains User Story 1 with acceptance scenarios (specs/001-spec-workflow/spec.md): (1) /speckit.specify creates spec, (2) /speckit.plan produces plan + artifacts and Constitution Check passes
- [x] T008 [US1] Confirm plan.md Summary and Technical Context describe Helm chart repo and spec workflow; Project Structure shows charts/ and specs/ (specs/001-spec-workflow/plan.md)
- [x] T009 [US1] Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root; must succeed and output FEATURE_DIR and include tasks.md in available docs
- [x] T010 [US1] Run `/speckit.analyze` (or equivalent analysis over spec.md, plan.md, tasks.md); address any CRITICAL findings or document acceptance of current state

**Checkpoint**: User Story 1 complete—workflow is in place and analyzable; no CRITICAL spec/plan/tasks inconsistencies

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and repo hygiene

- [x] T011 [P] Ensure README at repository root mentions Helm repo add command and points to `./charts`; optionally document pre-commit and speckit workflow (specs/ and .specify/)
- [x] T012 Validate quickstart.md: consumer steps (helm repo add, install) and contributor steps (branch, /speckit.specify, /speckit.plan, /speckit.tasks, helm lint/template) are accurate in specs/001-spec-workflow/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies—can start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1—validates constitution and chart baseline
- **Phase 3 (US1)**: Depends on Phase 2—verifies full workflow and runs analysis
- **Phase 4 (Polish)**: Depends on Phase 3—documentation and quickstart validation

### Parallel Opportunities

- T002 and T003 can run in parallel
- T005 and T006 can run in parallel
- T011 and T012 can run in parallel

---

## Implementation Strategy

### MVP (User Story 1)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Run `/speckit.analyze` and fix CRITICAL issues if any
5. Optionally complete Phase 4 for README and quickstart

---

## Notes

- No application code or new charts in this feature; tasks are verification and documentation.
- [P] = parallel-safe; [US1] = traceability to User Story 1.
- Commit after each task or logical group.
