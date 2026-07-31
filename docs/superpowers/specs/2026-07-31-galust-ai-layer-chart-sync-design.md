# Galust AI Layer Umbrella Chart Sync — Design

**Date:** 2026-07-31  
**Status:** Approved for planning  
**Chart:** `charts/galust-ai-layer`  
**Source of truth for this sync:** `ai-layer/*/helm` values + ingress manifests

## Goal

Bring the `galust-ai-layer` umbrella chart in line with the current production-shaped deploy configs under `ai-layer/*/helm`, and establish the umbrella as the **canonical** place for AI-layer Kubernetes values going forward.

CI cutover to install via the umbrella is **out of scope** for this change (follow-up).

## Decisions

| Decision | Choice |
| --- | --- |
| Sync source | `ai-layer/*/helm` (+ ingress YAMLs), not docker-compose |
| Component set | Prod core: drop `mcpUseCase`; add `orchestratorScheduler`; keep backend / mcp / mcpProducts / orchestrator / frontend; skip `productsOpenapiServer` |
| Ownership | Umbrella is canonical; `ai-layer/*/helm` becomes reference-only (documented) |
| Implementation approach | In-place sync of existing umbrella (`Chart.yaml`, `values.yaml`, README, examples) |
| Secrets | Remain external Kubernetes Secrets; do not copy plaintext tokens from `backend/helm/strapi.yaml` into the chart |

## Component inventory

| Values key | Action | Notes |
| --- | --- | --- |
| `backend` | Keep + sync | TrueCharts `strapi` alias; non-secret env from `backend/helm/strapi.yaml` |
| `mcp` | Keep + sync | Config + session-affinity ingress from `mcp/helm` |
| `mcpProducts` | Keep + sync | Probes, resources, replicas, config + ingress from `mcp-products/helm` |
| `orchestrator` | Keep + sync | Config/ingress from `orchestrator/helm/values.yaml` |
| `orchestratorScheduler` | **Add** | New `base` dependency alias from `orchestrator/helm/values-scheduler.yaml` |
| `frontend` | Keep | No ai-layer helm source; leave current values |
| `mcpUseCase` | **Remove** | Service removed from ai-layer; use cases live on mcp-products |

## Config, URLs & ingress

### Global anchors

Keep existing global URL anchors. Add:

- `MCP_PRODUCTS_URL` → `https://mcp-products.galust.ai`
- `MCP_PRODUCTS_HOST` → `mcp-products.galust.ai`

### mcp

- Cluster-internal OpenAPI / backend URLs (as in `mcp/helm/values.yaml`)
- `MCP_SSE_HEARTBEAT_MS: "20000"`
- Drop noisy debug defaults where prod has them commented/off
- Ingress on `mcp.galust.ai`: long proxy timeouts, buffering off, `nginx.ingress.kubernetes.io/upstream-hash-by: "$http_mcp_session_id"`

### mcpProducts

- `replicaCount: 2`
- Resources, startup/readiness/liveness probes, prometheus `podAnnotations`
- Config: session limits, heartbeat, `NODE_OPTIONS`, `MCP_PRODUCTS_MAX_SPEC_BYTES`, cluster-style `ORCHESTRATOR_ENDPOINT`, production `AI_LAYER_BACKEND_URL` as in live values
- Ingress on `mcp-products.galust.ai` with the same session-affinity / timeout pattern

### orchestrator

- Align config with `orchestrator/helm/values.yaml`: `QDRANT_URL`, `REDIS_URL`, `PROMPT_SOURCE`, `CLOUDBROWSER_URL`, `AI_LAYER_BACKEND_URL`, `MCP_CORE_BASE_URL`, `MCP_PRODUCTS_BASE_URL`, `PERSIST_CONVERSATION_TOOL_CALLS`, `SCHEDULED_TRIGGERS_ENABLED: "false"`
- Keep `/orchestrator` ingress on `api.galust.ai`
- CORS allow-headers include `X-Dexatel-Key` (match prod)

### orchestratorScheduler

- Same image and `envFrom.secret` as orchestrator (`ai-layer-orchestrator`)
- `fullnameOverride: ai-layer-orchestrator-scheduler`
- `replicaCount: 1`, autoscaling disabled, ingress disabled
- `SCHEDULED_TRIGGERS_ENABLED: "true"`, `SCHEDULED_TRIGGERS_POLL_INTERVAL_MS: "60000"`

### backend

- Add non-secret in-cluster URLs used in prod (e.g. `MCP_BASE_URL`, `MCP_PRODUCTS_BASE_URL`) via TrueCharts env shape
- Sensitive values (`JWT_*`, `APP_KEYS`, API tokens, encryption keys, Sentry DSN) stay in external secret `ai-layer-strapi` / existing secret refs — not inlined

## Documentation & versioning

- Update `charts/galust-ai-layer/README.md` for new component set, secrets table, MCP hosts, scheduler
- Bump chart `version` / `appVersion` to `0.2.0` (breaking component set change: remove mcpUseCase, add scheduler)
- Refresh `examples/galust-ai-layer/values.test.yaml`
- In ai-layer: short note that `*/helm` values are reference-only; canonical values live in `dasmeta/helm` `charts/galust-ai-layer`

## Validation

- `helm dependency update charts/galust-ai-layer`
- `helm lint charts/galust-ai-layer`
- `helm template` with defaults and with `orchestratorScheduler.enabled=false` / `frontend.enabled=false`
- Spot-check rendered MCP ingress annotations and scheduler env

## Out of scope

- Rewiring CI/CD to deploy via the umbrella
- Adding `productsOpenapiServer`
- Provisioning Redis, Qdrant, IAM, External Secrets, or databases
- Removing checked-in secrets from `ai-layer/backend/helm/strapi.yaml` (separate hygiene)

## Success criteria

1. Umbrella chart no longer references `mcpUseCase`
2. Umbrella can render `orchestratorScheduler` with scheduled triggers enabled and API orchestrator with them disabled
3. MCP and mcp-products ingress manifests include session affinity annotations matching ai-layer ingress files
4. Component config keys match the corresponding `ai-layer/*/helm` values (non-secret)
5. README and example values reflect the new component set
6. ai-layer documents that the umbrella is canonical
