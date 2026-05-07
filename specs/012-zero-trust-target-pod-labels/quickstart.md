# Quickstart: Zero Trust Target Pod Labels

Run from the repository root.

## Render the custom target label example

```bash
helm template ztm-target-pod-labels ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/target-pod-labels.yaml
```

Expected selector snippets:

```yaml
podSelector:
  matchLabels:
    app: backend
    component: api
```

```yaml
selector:
  matchLabels:
    app: backend
    component: api
```

## Run the focused regression check

```bash
./charts/zero-trust-mesh/tests/render-target-pod-labels.sh ./charts/zero-trust-mesh
```

Expected: exit code `0`.

## Verify default fallback behavior

```bash
helm template ztm ./charts/zero-trust-mesh -n default
```

Expected selector snippet:

```yaml
matchLabels:
  app.kubernetes.io/name: backend
```

## Lint the chart

```bash
helm lint ./charts/zero-trust-mesh
```

Expected: `0 chart(s) failed`.

## Render existing examples for regression

```bash
helm template ztm-namespace ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/values.namespace.yaml
helm template ztm-full ./charts/zero-trust-mesh -n default -f ./examples/zero-trust-mesh/values.full.yaml
```

Expected: both commands exit `0`.
