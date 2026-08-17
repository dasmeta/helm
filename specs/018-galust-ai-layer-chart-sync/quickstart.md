# Quickstart: Galust AI Layer Chart Sync

Run from the helm repository root.

## Lint

```bash
helm lint ./charts/base
helm lint ./charts/galust-ai-layer
```

Expected: `0 chart(s) failed`.

## Base session affinity example

```bash
helm template test ./charts/base -f ./examples/base/with-session-affinity.yaml
```

Expected: Service spec includes `sessionAffinity: ClientIP` and `timeoutSeconds: 10800`.

## Base default (no affinity)

```bash
helm template test ./charts/base -f ./examples/base/basic.yaml
```

Expected: Service spec has no `sessionAffinity` field.

## Umbrella default render

```bash
helm template galust-ai-layer ./charts/galust-ai-layer -n ai-layer
```

Expected:

- No `mcpUseCase` / `ai-layer-mcp-use-case`
- Includes `ai-layer-orchestrator-scheduler`
- mcp-products Service has `sessionAffinity: ClientIP`
- No mcp-products affinity hook Job
- Orchestrator `MCP_CORE_BASE_URL` is `http://ai-layer-mcp/mcp`

## Disable toggles

```bash
helm template galust-ai-layer ./charts/galust-ai-layer -n ai-layer \
  --set orchestratorScheduler.enabled=false \
  --set frontend.enabled=false
```

Expected: no `ai-layer-orchestrator-scheduler` or `ai-layer-frontend` workloads.

## Example overlay

```bash
helm template galust-ai-layer ./charts/galust-ai-layer -n ai-layer \
  -f ./examples/galust-ai-layer/values.test.yaml
```

Expected: exits `0`.
