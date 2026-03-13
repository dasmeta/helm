# Tasks: Gateway API example + Constitution “Examples for new abilities” (006)

**Input**: [plan.md](./plan.md)  
**Goal**: Add example for infrastructure.parameters and constitution rule for new abilities.

## Phase 1: Example and constitution

- [x] T001 **Example file**: Create `examples/gateway-api/infrastructure-parameters.yaml` with top-line command and values for `gateways[].infrastructure.parameters`.
- [x] T002 **Constitution**: Add “Examples for new abilities” under Additional Constraints; bump version to 1.3.0 and Last Amended 2026-03-13.
- [x] T003 **Validation**: Run `helm template` and `helm lint` with the new example; confirm 0 chart(s) failed.
