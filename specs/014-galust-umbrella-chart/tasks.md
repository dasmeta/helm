# Tasks: Galust AI Layer Umbrella Chart

**Input**: `specs/014-galust-umbrella-chart/spec.md`, `specs/014-galust-umbrella-chart/plan.md`

## Phase 1: Setup

- [x] T001 Create Speckit package `specs/014-galust-umbrella-chart`
- [x] T002 Confirm source deployment values from `ai-layer`

## Phase 2: Chart Implementation

- [x] T003 Add `charts/galust-ai-layer/Chart.yaml` with base subchart aliases and component conditions
- [x] T004 Add default values for backend, mcp, mcp-use-case, and orchestrator
- [x] T005 Add optional docker registry pull-secret template
- [x] T006 Add chart README and notes

## Phase 3: Validation

- [x] T007 Run `helm dependency update charts/galust-ai-layer`
- [x] T008 Run `helm lint charts/galust-ai-layer`
- [x] T009 Render all components and disabled-component cases with `helm template`
