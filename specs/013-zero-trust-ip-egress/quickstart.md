# Quickstart: Zero Trust IP Egress

Run all commands from the repository root.

## Focused IP Egress Test

```bash
./charts/zero-trust-mesh/tests/render-ip-egress.sh ./charts/zero-trust-mesh
```

Expected: command exits with status `0`.

## Chart Lint

```bash
helm lint ./charts/zero-trust-mesh
```

Expected: `1 chart(s) linted, 0 chart(s) failed`.

## Default Render

```bash
helm template ztm-default ./charts/zero-trust-mesh -n default
```

Expected: command exits with status `0` and includes existing service and host outputs plus the default sample IP rule from `values.yaml`.

## Runnable IP Egress Example

```bash
helm template ztm-ip-egress ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/ip-egress.yaml
```

Expected: command exits with status `0`, renders a ServiceEntry with `resolution: NONE`, and renders a NetworkPolicy with `ipBlock`.

## Existing Example Regression

```bash
helm template ztm-target-pod-labels ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/target-pod-labels.yaml
helm template ztm-namespace ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/values.namespace.yaml
helm template ztm-full ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/values.full.yaml
```

Expected: each command exits with status `0`.
