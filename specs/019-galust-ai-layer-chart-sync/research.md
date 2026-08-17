# Research: Galust AI Layer Chart Sync

## Decision: `ai-layer/*/helm` is the sync source

- **Decision**: Copy production-shaped values and ingress from per-service helm files, not docker-compose / `.env`.
- **Rationale**: Compose is dev-shaped (debug flags, local hostnames). Live deploy files already encode session hashing, HPA, and in-cluster URLs.
- **Alternatives considered**: Compose-first sync (rejected: would ship debug defaults); live cluster dump (rejected: not in repo, secrets risk).

## Decision: Prod-core component set

- **Decision**: Drop `mcpUseCase`; add `orchestratorScheduler`; keep backend, mcp, mcpProducts, orchestrator, frontend; skip `productsOpenapiServer`.
- **Rationale**: Use cases now live on mcp-products. Scheduler is a second orchestrator Deployment with triggers enabled. OpenAPI stub is local-dev only.
- **Alternatives considered**: Keep mcpUseCase disabled (rejected: dead dependency and image). Include products-openapi-server (rejected: not production).

## Decision: In-cluster MCP URLs for orchestrator

- **Decision**: `MCP_CORE_BASE_URL=http://ai-layer-mcp/mcp` and `MCP_PRODUCTS_BASE_URL=http://ai-layer-mcp-products/mcp`.
- **Rationale**: Public ingress hashing by `$remote_addr` is unstable for pod egress / multi-replica hairpin and caused Session not found (`-32001`) on nested use-case tools.
- **Existing evidence**: `ai-layer/orchestrator/helm/values.yaml` comments and mcp-products ingress `$remote_addr`.

## Decision: Native Service sessionAffinity on `charts/base`

- **Decision**: Render `spec.sessionAffinity` and `spec.sessionAffinityConfig` from values; mcp-products sets `ClientIP` / 10800s.
- **Rationale**: Kubernetes Service already supports ClientIP stickiness. A Helm hook Job that `kubectl patch`es the Service after every upgrade is extra RBAC, a race with the Service, and duplicates what the API already offers.
- **Alternatives considered**:
  - Post-install/post-upgrade hook Job (implemented then removed): works around missing base fields, too complicated.
  - `ensure-session-affinity.sh` in CI only: does not help umbrella `helm install` from scratch.
  - Ingress-only hashing: insufficient for in-cluster ClusterIP callers.

## Decision: Secrets stay external

- **Decision**: Do not copy JWT, APP_KEYS, API tokens, encryption keys, or Sentry DSNs from `backend/helm/strapi.yaml` into the umbrella.
- **Rationale**: Chart values are committed; secrets belong in Kubernetes Secrets / External Secrets.

## Compatibility Notes

- `base` sessionAffinity is additive; empty string / empty config render nothing.
- Existing base consumers are unchanged at 0.3.33 defaults (sessionAffinity omitted). 0.3.32 on main already shipped ExternalSecret v1.
- Umbrella 0.2.x is a breaking component-set change versus 0.1.x (`mcpUseCase` removed).
