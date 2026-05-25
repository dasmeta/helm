# Quickstart: Service-Level Deny All

Run these commands from the repository root.

## Focused service deny-all assertion

```bash
./charts/zero-trust-mesh/tests/render-service-deny-all.sh ./charts/zero-trust-mesh
```

Expected: exits with status `0` after implementation.

## Chart lint

```bash
helm lint ./charts/zero-trust-mesh
```

Expected: `0 chart(s) failed`.

## Default render regression

```bash
helm template ztm-default ./charts/zero-trust-mesh -n default
```

Expected: renders successfully and does not include service-level deny-all resources.

## Existing examples

```bash
helm template ztm-namespace ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/values.namespace.yaml
helm template ztm-full ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/values.full.yaml
helm template ztm-target-pod-labels ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/target-pod-labels.yaml
helm template ztm-ip-egress ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/ip-egress.yaml
```

Expected: each command exits with status `0`.

## New example

```bash
helm template ztm-service-deny-all ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/service-deny-all.yaml
```

Expected: renders service-level deny-all resources for the selected workload only.
