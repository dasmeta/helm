# Feature Specification: Galust AI Layer Chart Sync

**Feature Branch**: `019-galust-ai-layer-chart-sync`  
**Created**: 2026-07-31  
**Status**: Implemented  
**Input**: Sync `charts/galust-ai-layer` with current `ai-layer/*/helm` production-shaped values, make the umbrella the canonical deploy chart, and add native Service `sessionAffinity` on `charts/base` so mcp-products does not need a post-install patch Job.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Install the current AI layer stack from the umbrella (Priority: P1)

As an operator, I can install `galust-ai-layer` and get the production-shaped component set (backend, mcp, mcp-products, orchestrator, orchestrator scheduler, frontend) without a removed mcp-use-case service.

**Why this priority**: The umbrella still shipped `mcpUseCase` after that service was removed from ai-layer. A from-scratch install must match the live stack.

**Independent Test**: `helm template galust-ai-layer charts/galust-ai-layer -n ai-layer` contains no `mcpUseCase` / `ai-layer-mcp-use-case` and includes `ai-layer-orchestrator-scheduler`.

**Acceptance Scenarios**:

1. **Given** default chart values, **When** the chart is rendered, **Then** there is no mcp-use-case workload, Service, or values key.
2. **Given** default chart values, **When** the chart is rendered, **Then** `orchestratorScheduler` is present with `SCHEDULED_TRIGGERS_ENABLED=true` and the API orchestrator has `SCHEDULED_TRIGGERS_ENABLED=false`.
3. **Given** `--set orchestratorScheduler.enabled=false`, **When** the chart is rendered, **Then** no scheduler Deployment or Service is created.

---

### User Story 2 - Match production env, ingress, and scaling (Priority: P1)

As an operator, I can deploy with values that match current `ai-layer/*/helm` (non-secret): in-cluster MCP URLs, evaluation env, CORS headers, mcp-products HPA, session caps, and ingress hashing.

**Why this priority**: Drift caused Session-not-found on nested MCP tools and omitted evaluation/CORS/HPA settings that production already uses.

**Independent Test**: Render defaults and assert orchestrator `MCP_CORE_BASE_URL` / `MCP_PRODUCTS_BASE_URL` are in-cluster, evaluation keys are present, mcp-products HPA is 2–5 at 70% CPU and memory, `MCP_PRODUCTS_MAX_SESSIONS` is `80`, mcp ingress hashes `$http_mcp_session_id`, mcp-products ingress hashes `$remote_addr`.

**Acceptance Scenarios**:

1. **Given** default values, **When** orchestrator is rendered, **Then** MCP URLs are `http://ai-layer-mcp/mcp` and `http://ai-layer-mcp-products/mcp`.
2. **Given** default values, **When** orchestrator ingress is rendered, **Then** CORS allow-headers include `X-Product-Uid`, `X-Mcp-Upstream-Authorization`, `X-Galust-Evaluation-Source`, and `X-Galust-UI-Capabilities`.
3. **Given** default values, **When** mcp-products is rendered, **Then** an HPA exists with min 2 / max 5 and CPU+memory utilization 70.

---

### User Story 3 - Pin mcp-products sessions without a patch Job (Priority: P1)

As a chart consumer, I can set Service `sessionAffinity` on `dasmeta/base` from values so in-cluster MCP sessions stick to one pod, without a Helm hook that patches the Service after install.

**Why this priority**: Streamable HTTP sessions are pod-local. A kubectl patch Job is fragile; native Service fields are the Kubernetes contract.

**Independent Test**: `helm template test charts/base -f examples/base/with-session-affinity.yaml` includes `sessionAffinity: ClientIP`. Default `galust-ai-layer` render of `ai-layer-mcp-products` Service includes ClientIP and timeout 10800, and no affinity hook Job.

**Acceptance Scenarios**:

1. **Given** `service.sessionAffinity` is unset on base, **When** the chart is rendered, **Then** the Service spec has no `sessionAffinity` field.
2. **Given** `sessionAffinity: ClientIP` and a timeout config, **When** the chart is rendered, **Then** those fields appear on the Service spec.
3. **Given** default `galust-ai-layer` values, **When** the chart is rendered, **Then** there is no post-install Job/RBAC that patches Services.

---

### User Story 4 - Discover how to install and override (Priority: P2)

As an operator, I can read the umbrella README and example overlay and know the component set, secrets, public hosts, and how to disable scheduler/frontend.

**Why this priority**: The umbrella is the canonical deploy chart; docs must match the new component set.

**Independent Test**: README lists scheduler and mcp-products hosts, has no mcpUseCase, and `helm template ... -f examples/galust-ai-layer/values.test.yaml` exits 0.

**Acceptance Scenarios**:

1. **Given** the chart README, **When** an operator scans the component table, **Then** they see backend, mcp, mcpProducts, orchestrator, orchestratorScheduler, and frontend.
2. **Given** `examples/galust-ai-layer/values.test.yaml`, **When** they run the top-line helm command, **Then** the chart renders.

### Edge Cases

- YAML anchors in `values.yaml` are resolved before Helm merges extra values files; overriding only `global` in a `-f` file does not rewrite already-resolved aliases.
- Secrets stay external; plaintext tokens from `ai-layer/backend/helm/strapi.yaml` MUST NOT be copied into the umbrella.
- `productsOpenapiServer` is a dev stub and MUST NOT be added to the default prod-core set.
- CI cutover from per-service `ai-layer/*/helm` releases to this umbrella is out of scope.
- Empty `service.sessionAffinity` / empty `sessionAffinityConfig` MUST NOT render those keys (backward compatible for all existing base consumers).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `charts/galust-ai-layer` MUST NOT depend on or render `mcpUseCase`.
- **FR-002**: The umbrella MUST include an `orchestratorScheduler` `base` alias, enabled by default, with scheduled triggers on and ingress off.
- **FR-003**: MCP, mcp-products, orchestrator, and backend non-secret config MUST match the corresponding `ai-layer/*/helm` values used in production.
- **FR-004**: mcp-products MUST render HPA min 2 / max 5 with CPU and memory utilization 70, replicaCount 2, and `MCP_PRODUCTS_MAX_SESSIONS` of `80`.
- **FR-005**: mcp ingress MUST hash by `$http_mcp_session_id`; mcp-products ingress MUST hash by `$remote_addr`.
- **FR-006**: Orchestrator MUST use in-cluster MCP Service URLs and evaluation execution env keys from current orchestrator helm values.
- **FR-007**: `charts/base` MUST render `spec.sessionAffinity` and `spec.sessionAffinityConfig` from values when set.
- **FR-008**: `galust-ai-layer` mcp-products MUST set `service.sessionAffinity: ClientIP` and timeout 10800 via base values, not a hook Job.
- **FR-009**: Chart README, NOTES, and `examples/galust-ai-layer/values.test.yaml` MUST reflect the new component set and MCP products host.
- **FR-010**: `galust-ai-layer` MUST bump to at least `0.2.0` (component-set change). `charts/base` MUST bump to `0.3.33` for the Service field addition.
- **FR-011**: Sensitive values MUST remain in external Kubernetes Secrets.
- **FR-012**: `examples/base/with-session-affinity.yaml` MUST demonstrate the new base Service fields.

### Key Entities

- **Umbrella component alias**: A `Chart.yaml` dependency (`backend`, `mcp`, `mcpProducts`, `orchestrator`, `orchestratorScheduler`, `frontend`) gated by `<alias>.enabled`.
- **Production-shaped values**: Non-secret env, probes, ingress, and HPA copied from `ai-layer/*/helm`.
- **Service session affinity**: Kubernetes Service `sessionAffinity` (`None`/`ClientIP`) plus optional `sessionAffinityConfig.clientIP.timeoutSeconds`.

### Assumptions

- Operators create `ecr-secret` and app secrets before install.
- Redis, Qdrant, DNS, TLS, and IAM stay outside this chart.
- Per-service files under `ai-layer/*/helm` remain reference snapshots until CI cutover.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `helm lint charts/galust-ai-layer` and `helm lint charts/base` complete with 0 failed charts.
- **SC-002**: Default `helm template` of the umbrella contains no `mcpUseCase` / `ai-layer-mcp-use-case`.
- **SC-003**: Rendered mcp-products Service includes `sessionAffinity: ClientIP` and timeout `10800` with no affinity patch Job.
- **SC-004**: Rendered orchestrator config includes in-cluster MCP URLs and `EVALUATION_EXECUTION_ENABLED`.
- **SC-005**: A reviewer can find the component table, secrets list, and session-affinity values in the umbrella README in under 5 minutes.
