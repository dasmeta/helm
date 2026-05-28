# Feature Specification: Galust AI Layer Umbrella Chart

**Feature Branch**: `014-galust-umbrella-chart`  
**Created**: 2026-05-11  
**Status**: Draft  
**Input**: Jira `DMVP-10005`, Jira `DMVP-10093`, and repo evidence from `ai-layer`

## User Scenarios & Testing

### User Story 1 - Install All Galust Components (Priority: P1)

Platform operators can install one Helm chart to deploy the Galust backend, MCP, MCP use-case service, MCP products service, orchestrator, and frontend into their own EKS cluster.

**Why this priority**: This is the core onboarding deliverable.

**Independent Test**: Render the chart with default values and confirm all component releases are present.

**Acceptance Scenarios**:

1. **Given** default chart values, **When** the chart is rendered, **Then** backend, mcp, mcp-use-case, mcp-products, orchestrator, and frontend resources are included.
2. **Given** an existing ECR pull secret name, **When** the chart is installed, **Then** every component references that pull secret.

### User Story 2 - Selectively Disable Components (Priority: P1)

Platform operators can deploy only the components they need for a given environment.

**Why this priority**: The ticket explicitly asks for deploy options per component.

**Independent Test**: Render the chart with each component disabled and confirm that component is omitted while the others remain.

**Acceptance Scenarios**:

1. **Given** `backend.enabled=false`, **When** the chart is rendered, **Then** backend resources are omitted.
2. **Given** `mcp.enabled=false`, **When** the chart is rendered, **Then** mcp resources are omitted.
3. **Given** `mcpUseCase.enabled=false`, **When** the chart is rendered, **Then** mcp-use-case resources are omitted.
4. **Given** `orchestrator.enabled=false`, **When** the chart is rendered, **Then** orchestrator resources are omitted.
5. **Given** `frontend.enabled=false`, **When** the chart is rendered, **Then** frontend resources are omitted.

### User Story 3 - Configure ECR Pull Access (Priority: P2)

Platform operators can point the deployment at a Kubernetes docker registry secret or have the chart render one from provided docker config JSON.

**Why this priority**: Pull access is necessary for private images but AWS IAM trust remains outside this chart.

**Independent Test**: Render the chart with `imagePullSecret.create=true` and confirm a `kubernetes.io/dockerconfigjson` Secret is produced.

## Requirements

### Functional Requirements

- **FR-001**: The chart MUST expose independent enable flags for `backend`, `mcp`, `mcpUseCase`, `mcpProducts`, `orchestrator`, and `frontend`.
- **FR-002**: The chart MUST use `dasmeta/base` subchart aliases for the long-running service workloads.
- **FR-003**: The chart MUST carry defaults derived from the current `ai-layer` deployment files.
- **FR-004**: The chart MUST allow image repository, tag, pull policy, and pull secrets to be overridden per component.
- **FR-005**: The chart MUST document ECR/IAM provisioning as out of scope.
- **FR-006**: The frontend MUST default to image `565580475168.dkr.ecr.eu-central-1.amazonaws.com/ai-layer-frontend-app:latest`.
- **FR-007**: The frontend MUST expose service and container port `80`.

## Success Criteria

### Measurable Outcomes

- **SC-001**: `helm lint charts/galust-ai-layer` succeeds after dependencies are built.
- **SC-002**: `helm template` succeeds with default values.
- **SC-003**: `helm template` succeeds when any one component is disabled.
- **SC-004**: The README contains install and pull-secret examples.
- **SC-005**: Rendered default manifests include a frontend workload and Service using port `80`.
