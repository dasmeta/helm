# Render Contract: Galust AI Layer Chart Sync

## Umbrella defaults

Command:

```bash
helm template galust-ai-layer ./charts/galust-ai-layer -n ai-layer
```

Expected output:

- Does not contain `mcpUseCase`, `mcp-use-case`, or `ai-layer-mcp-use-case`.
- Includes resources named `ai-layer-orchestrator-scheduler`.
- Includes `SCHEDULED_TRIGGERS_ENABLED: "false"` (API) and `"true"` (scheduler).
- mcp Ingress annotation `nginx.ingress.kubernetes.io/upstream-hash-by: $http_mcp_session_id`.
- mcp-products Ingress annotation `nginx.ingress.kubernetes.io/upstream-hash-by: $remote_addr`.
- mcp-products Service `sessionAffinity: ClientIP` and `sessionAffinityConfig.clientIP.timeoutSeconds: 10800`.
- mcp-products HPA minReplicas 2, maxReplicas 5, CPU and memory averageUtilization 70.
- Orchestrator env `MCP_CORE_BASE_URL: http://ai-layer-mcp/mcp` and `MCP_PRODUCTS_BASE_URL: http://ai-layer-mcp-products/mcp`.
- Orchestrator env `EVALUATION_EXECUTION_ENABLED: "true"`.
- Orchestrator CORS headers include `X-Dexatel-Key`, `X-Product-Uid`, `X-Mcp-Upstream-Authorization`, `X-Galust-Evaluation-Source`, `X-Galust-UI-Capabilities`.
- Does not include a Job/Role that patches Services for session affinity.

## Base affinity example

Command:

```bash
helm template test ./charts/base -f ./examples/base/with-session-affinity.yaml
```

Expected output:

- Service `spec.sessionAffinity` is `ClientIP`.
- Service `spec.sessionAffinityConfig.clientIP.timeoutSeconds` is `10800`.

## Base default

Command:

```bash
helm template test ./charts/base -f ./examples/base/basic.yaml
```

Expected output:

- Service spec does not include `sessionAffinity` or `sessionAffinityConfig`.
