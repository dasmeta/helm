# Data Model: Galust AI Layer Chart Sync

## UmbrellaComponent

One aliased subchart under `charts/galust-ai-layer`.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `enabled` | boolean | yes | Gate for the Chart.yaml `condition`. |
| `fullnameOverride` | string | no | Kubernetes resource name prefix. |
| `config` | map | no | Container env for `base` aliases. |
| `ingress` | object | no | Public ingress when enabled. |
| `envFrom.secret` | string | no | External Secret name loaded as env. |

Default aliases: `backend` (TrueCharts strapi), `mcp`, `mcpProducts`, `orchestrator`, `orchestratorScheduler`, `frontend`.

Removed alias: `mcpUseCase`.

## ServiceSessionAffinity

Values on `charts/base` `service.*` rendered onto the Kubernetes Service.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `sessionAffinity` | string | no | `ClientIP` or omit/`None`. Empty string does not render. |
| `sessionAffinityConfig` | object | no | Optional; typically `clientIP.timeoutSeconds`. Empty map does not render. |

mcp-products umbrella defaults:

| Field | Value |
|-------|--------|
| `sessionAffinity` | `ClientIP` |
| `sessionAffinityConfig.clientIP.timeoutSeconds` | `10800` |

## McpProductsRuntime

Production-shaped mcp-products settings synced from `ai-layer/mcp-products/helm`.

| Field | Value |
|-------|--------|
| `replicaCount` | `2` |
| `autoscaling.minReplicas` / `maxReplicas` | `2` / `5` |
| `targetCPUUtilizationPercentage` | `70` |
| `targetMemoryUtilizationPercentage` | `70` |
| `config.MCP_PRODUCTS_MAX_SESSIONS` | `"80"` |
| ingress `upstream-hash-by` | `$remote_addr` |

## OrchestratorRuntime

| Field | API orchestrator | Scheduler |
|-------|------------------|-----------|
| `SCHEDULED_TRIGGERS_ENABLED` | `"false"` | `"true"` |
| `MCP_CORE_BASE_URL` | `http://ai-layer-mcp/mcp` | (inherits secret/config as in values) |
| `MCP_PRODUCTS_BASE_URL` | `http://ai-layer-mcp-products/mcp` | |
| `EVALUATION_EXECUTION_ENABLED` | `"true"` | unset |
| ingress | `/orchestrator` on `api.galust.ai` | disabled |
