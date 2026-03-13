# Tasks: Gateway API infrastructure.parameters (005)

**Input**: [spec.md](./spec.md), [plan.md](./plan.md)  
**Goal**: Add `gateways[].infrastructure.parameters`; chart generates ConfigMap and sets `parametersRef` when non-empty; preserve manual `parametersRef`.

## Phase 1: Templates and helpers

- [x] T001 **Helper**: Add `gateway-api.infrastructureConfigMapName` in `charts/gateway-api/templates/_helpers.tpl`.
- [x] T002 **ConfigMap template**: Create `charts/gateway-api/templates/gateway-infrastructure-configmap.yaml` (emit ConfigMap per gateway with non-empty parameters).
- [x] T003 **Gateway template**: In `charts/gateway-api/templates/gateway.yaml`, set `parametersRef` to generated ConfigMap when `parameters` present; else keep user `parametersRef`.

## Phase 2: Docs and values

- [x] T004 **values.yaml**: Document `infrastructure.parameters` with commented examples in `charts/gateway-api/values.yaml`.
- [x] T005 **README**: Update `charts/gateway-api/README.md` (values table + prose for parameters).

## Phase 3: Validation and version

- [x] T006 **Validation**: Run `helm lint` and `helm template` (default, one/two gateways with parameters); verify ConfigMap and parametersRef.
- [x] T007 **Version bump**: Bump `version` in `charts/gateway-api/Chart.yaml` (PATCH).
