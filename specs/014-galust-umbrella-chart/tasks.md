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

## Phase 4: DMVP-10093 Support Frontend

- [x] T010 [US1] Add frontend `base` alias dependency in `charts/galust-ai-layer/Chart.yaml`
- [x] T011 [US1] Add frontend defaults in `charts/galust-ai-layer/values.yaml`
- [x] T012 [US1] Update enabled component output in `charts/galust-ai-layer/templates/NOTES.txt`
- [x] T013 [US1] Update component, prerequisite, service, and validation documentation in `charts/galust-ai-layer/README.md`
- [x] T014 [US1] Update `examples/galust-ai-layer/values.test.yaml` to demonstrate frontend overrides
- [x] T015 Bump `charts/galust-ai-layer/Chart.yaml` version
- [x] T016 Run `helm dependency update charts/galust-ai-layer`
- [x] T017 Run `helm lint charts/galust-ai-layer`
- [x] T018 Run `helm template galust-ai-layer charts/galust-ai-layer -n ai-layer`
- [x] T019 Run `helm template galust-ai-layer charts/galust-ai-layer -n ai-layer --set frontend.enabled=false`
- [x] T020 Run `helm template galust-ai-layer charts/galust-ai-layer -n ai-layer -f examples/galust-ai-layer/values.test.yaml`
