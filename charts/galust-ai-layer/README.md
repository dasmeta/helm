# Galust AI Layer

Umbrella Helm chart for deploying the Galust AI layer stack into a Kubernetes or EKS cluster.

## What This Chart Deploys

This chart is an umbrella chart for the Galust AI layer services. It wraps the published `dasmeta/base` chart once per component and deploys:

- Strapi backend
- MCP
- MCP use-case service
- Orchestrator

The chart manages Kubernetes workload configuration for these services. It does not provision cloud infrastructure, databases, DNS records, TLS issuers, IAM roles, ECR policies, or external secrets.

## Components

The chart wraps the published `dasmeta/base` chart with one alias per deployable component:

| Component | Values key | Default |
| --- | --- | --- |
| Strapi backend | `backend.enabled` | `true` |
| MCP | `mcp.enabled` | `true` |
| MCP use-case service | `mcpUseCase.enabled` | `true` |
| Orchestrator | `orchestrator.enabled` | `true` |

Each component can be disabled independently:

```bash
helm upgrade --install galust-ai-layer ./charts/galust-ai-layer \
  -n ai-layer \
  --create-namespace \
  --set mcpUseCase.enabled=false
```

## Prerequisites

Before deploying, confirm the target cluster has:

- Kubernetes access through a working `kubectl` context.
- Helm 3 installed locally.
- Access to the `dasmeta` Helm repository, because this chart depends on `dasmeta/base`.
- AWS access to the target account, usually through an AWS SSO permission set and account assignment managed outside this chart.
- Namespace access for `ai-layer`, or permission to create it.
- Image pull access for the private ECR images.
- ECR read access for the private repositories used by the backend, MCP, MCP use-case, and orchestrator images.
- Required application secrets already created in the namespace.
- Database connectivity for the backend.
- A PVC or storage class suitable for backend uploads.
- Ingress controller installed if ingress is enabled.
- DNS records pointing the public hosts to the ingress/load balancer.
- TLS/cert-manager setup if the default TLS annotations and secrets are used.

If AWS access is managed through the Terraform SSO/RBAC modules, create or assign an AWS SSO permission set before deploying this chart. The permission set should allow the operator or automation role to:

- Read private ECR repositories and get ECR authorization tokens.
- Access the target EKS cluster and update Kubernetes resources in the `ai-layer` namespace.
- Create or update Kubernetes Secrets used by the chart, including `ecr-secret`, `ai-layer-strapi`, `db-ai-layer-strapi`, `ai-layer-mcp`, `ai-layer-mcp-use-case`, and `ai-layer-orchestrator`.
- If `ecrCredentialsRefresh.enabled=true`, provide an AWS identity for the refresh job with `ecr:GetAuthorizationToken`.

Required default Kubernetes objects:

| Object | Default name | Used by |
| --- | --- | --- |
| Docker registry pull secret | `ecr-secret` | all components |
| Backend app secret | `ai-layer-strapi` | backend |
| Backend DB host secret | `db-ai-layer-strapi`, key `host` | backend |
| Backend DB port | `backend.config.DATABASE_PORT`, default `5432` | backend |
| Backend DB password secret | `db-ai-layer-strapi`, key `password` | backend |
| Backend uploads PVC | `ai-layer-strapi-uploads` | backend |
| MCP secret | `ai-layer-mcp` | MCP |
| MCP use-case secret | `ai-layer-mcp-use-case` | MCP use-case |
| Orchestrator secret | `ai-layer-orchestrator` | orchestrator |

External dependencies such as Redis, Qdrant, Langfuse, OpenAI credentials, database provisioning, External Secrets, IAM trust, and DNS are handled outside this chart.

## Orchestrator Secret

The orchestrator reads sensitive values from a Kubernetes Secret through `envFrom.secret`.

Default values:

```yaml
orchestrator:
  envFrom:
    secret: ai-layer-orchestrator
```

This means every key in the `ai-layer-orchestrator` Secret is exposed to the orchestrator container as an environment variable. The default secret should contain:

| Secret key | Purpose |
| --- | --- |
| `OPENAI_API_KEY` | OpenAI API access |
| `LANGFUSE_PUBLIC_KEY` | Langfuse public key |
| `LANGFUSE_SECRET_KEY` | Langfuse secret key |
| `CLOUDBROWSER_API_TOKEN` | Cloud browser access |
| `FIRECRAWL_API_KEY` | Firecrawl API access |
| `SENTRY_DSN` | Sentry project DSN |
| `AI_LAYER_BACKEND_API_TOKEN` | Backend API token |
| `MCP_USE_CASE_AUTH_TOKEN` | MCP use-case auth token |
| `SUPPORT_CHAT_CORE_PRODUCT_UID` | Support chat core product UID |

Create or update the secret before deploying:

```bash
kubectl create secret generic ai-layer-orchestrator \
  -n ai-layer \
  --from-literal=OPENAI_API_KEY='<openai-api-key>' \
  --from-literal=LANGFUSE_PUBLIC_KEY='<langfuse-public-key>' \
  --from-literal=LANGFUSE_SECRET_KEY='<langfuse-secret-key>' \
  --from-literal=CLOUDBROWSER_API_TOKEN='<cloudbrowser-api-token>' \
  --from-literal=FIRECRAWL_API_KEY='<firecrawl-api-key>' \
  --from-literal=SENTRY_DSN='<sentry-dsn>' \
  --from-literal=AI_LAYER_BACKEND_API_TOKEN='<backend-api-token>' \
  --from-literal=MCP_USE_CASE_AUTH_TOKEN='<mcp-use-case-auth-token>' \
  --from-literal=SUPPORT_CHAT_CORE_PRODUCT_UID='<support-chat-core-product-uid>' \
  --dry-run=client -o yaml | kubectl apply -f -
```

Use a different secret name if needed:

```bash
helm upgrade --install galust-ai-layer charts/galust-ai-layer \
  -n ai-layer \
  --create-namespace \
  --set orchestrator.envFrom.secret=my-orchestrator-secret
```

## Configure Public URLs

Public URLs are defined near the top of `values.yaml`:

```yaml
global:
  API_URL: &apiUrl https://api.galust.ai
  API_HOST: &apiHost api.galust.ai
  APP_URL: &appUrl https://app.galust.ai
  MCP_URL: &mcpUrl https://mcp.galust.ai
  MCP_HOST: &mcpHost mcp.galust.ai
  ADMIN_URL: &adminUrl https://api.galust.ai/admin
  OPENAPI_BASE_URL: &openapiBaseUrl https://api.galust.ai/api
  OPENAPI_SPEC_URL: &openapiSpecUrl https://api.galust.ai/documentation/openapi.json
  ORCHESTRATOR_ENDPOINT: &orchestratorEndpoint https://api.galust.ai/orchestrator/api/galust/ask
```

The rest of `values.yaml` reuses these values with YAML anchors, for example:

```yaml
backend:
  config:
    ADMIN_URL: *adminUrl
    BACKEND_URL: *apiUrl
  ingress:
    hosts:
      - host: *apiHost
```

Important: YAML anchors are resolved before Helm merges extra values files. If you deploy with `-f examples/galust-ai-layer/values.test.yaml` and only override `global`, Helm will not recalculate aliases already resolved in `values.yaml`. To change domains for another environment, either edit the full values file or provide a values file that also overrides the component `config` and `ingress` fields.

## Image Pull Access

The default values expect an existing Kubernetes docker registry secret named `ecr-secret`. The secret name is anchored once and reused by every component:

```yaml
imagePullSecret:
  name: &imagePullSecretName ecr-secret

imagePullSecrets:
  - name: *imagePullSecretName
```

The chart can also render the secret when `imagePullSecret.create=true`:

```bash
helm upgrade --install galust-ai-layer ./charts/galust-ai-layer \
  -n ai-layer \
  --create-namespace \
  --set imagePullSecret.create=true \
  --set-file imagePullSecret.dockerConfigJson=./dockerconfig.json
```

AWS IAM trust, ECR repository policies, role assumption, and External Secrets setup are intentionally outside this chart. Provide the resulting Kubernetes pull secret name through `imagePullSecret.name` and each component's `imagePullSecrets` override.

ECR authorization tokens expire. For long-running environments, enable the optional refresh CronJob or use another cluster-managed renewal mechanism such as External Secrets, a registry credential controller, or a platform-owned refresh job. This chart can reference an existing pull secret, render one from provided docker config JSON, or refresh the secret through the optional CronJob.

Example secret creation:

```bash
kubectl create namespace ai-layer

kubectl create secret docker-registry ecr-secret \
  -n ai-layer \
  --docker-server=565580475168.dkr.ecr.eu-central-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password='<ecr-login-password>'
```

## ECR Credentials Refresh

The chart can render an optional CronJob that refreshes the ECR docker registry secret before the token expires:

```yaml
ecrCredentialsRefresh:
  enabled: true
  schedule: "0 */6 * * *"
  registry: 565580475168.dkr.ecr.eu-central-1.amazonaws.com
  region: eu-central-1
  secretName: ecr-secret
```

The refresh job updates the same `kubernetes.io/dockerconfigjson` Secret referenced by component `imagePullSecrets`. It creates a namespaced `Role`, `RoleBinding`, `ServiceAccount`, and `CronJob`.

Use an existing Kubernetes Secret with AWS credentials:

```bash
kubectl create secret generic ecr-refresh-aws-credentials \
  -n ai-layer \
  --from-literal=AWS_ACCESS_KEY_ID='<aws-access-key-id>' \
  --from-literal=AWS_SECRET_ACCESS_KEY='<aws-secret-access-key>' \
  --dry-run=client -o yaml | kubectl apply -f -
```

Then enable the refresher:

```bash
helm upgrade --install galust-ai-layer charts/galust-ai-layer \
  -n ai-layer \
  --create-namespace \
  --set ecrCredentialsRefresh.enabled=true \
  --set ecrCredentialsRefresh.awsCredentialsSecret.name=ecr-refresh-aws-credentials
```

If the cluster uses IRSA or EKS Pod Identity, leave `awsCredentialsSecret.name` empty and annotate the refresh service account:

```yaml
ecrCredentialsRefresh:
  enabled: true
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/<role-name>
```

The AWS identity used by the refresh job needs permission to call `ecr:GetAuthorizationToken`. The refresh container uses `alpine` and installs `aws-cli`, `curl`, `ca-certificates`, and `coreutils` at runtime, so the namespace must allow outbound package download access or you must override `ecrCredentialsRefresh.image` with an internal image that already contains the required tools.

After installing, trigger the first refresh before private-image workloads need to pull:

```bash
kubectl create job \
  -n ai-layer \
  --from=cronjob/galust-ai-layer-ecr-refresh \
  galust-ai-layer-ecr-refresh-manual
```

## Backend Notes

The backend values use the existing Galust Strapi image and runtime defaults from `ai-layer/backend/helm/strapi.yaml`, but this umbrella chart does not provision AWS IAM or a managed database. Database secrets are created outside this chart. By default the backend expects:

- an `ai-layer-strapi` secret for Strapi application secrets
- `db-ai-layer-strapi` with key `host`
- `backend.config.DATABASE_PORT`, defaulting to `5432`
- `db-ai-layer-strapi` with key `password`
- a PVC named `ai-layer-strapi-uploads` for `/opt/app/public/uploads`

Override those names for environment-specific infrastructure.

If the database host and password are stored in one Kubernetes Secret, override the `extraEnv` references:

```yaml
backend:
  extraEnv:
    DATABASE_HOST:
      secretKeyRef:
        name: my-database-secret
        key: host
    DATABASE_PASSWORD:
      secretKeyRef:
        name: my-database-secret
        key: password
```

If the database port is also stored in the same database secret, override `DATABASE_PORT` from `config` with an `extraEnv` secret reference:

```yaml
backend:
  config:
    DATABASE_PORT: null
  extraEnv:
    DATABASE_HOST:
      secretKeyRef:
        name: db-ai-layer-strapi
        key: host
    DATABASE_PORT:
      secretKeyRef:
        name: db-ai-layer-strapi
        key: port
```

## Deploy

Run commands from the `helm` repository directory:

```bash
cd /Users/juliaaghamyan/Desktop/dasmeta/helm
helm dependency update charts/galust-ai-layer
```

Deploy with default `values.yaml`:

```bash
helm upgrade --install galust-ai-layer charts/galust-ai-layer \
  -n ai-layer \
  --create-namespace
```

Deploy with the test values example:

```bash
helm upgrade --install galust-ai-layer charts/galust-ai-layer \
  -n ai-layer \
  --create-namespace \
  -f examples/galust-ai-layer/values.test.yaml
```

Disable a component:

```bash
helm upgrade --install galust-ai-layer charts/galust-ai-layer \
  -n ai-layer \
  --create-namespace \
  --set mcpUseCase.enabled=false
```

## Post-Deploy Checks

```bash
kubectl get pods -n ai-layer
kubectl get svc -n ai-layer
kubectl get ingress -n ai-layer
kubectl describe pod -n ai-layer -l app=ai-layer-orchestrator
kubectl logs -n ai-layer deploy/ai-layer-orchestrator
```

Expected default service names:

- `ai-layer-strapi`
- `ai-layer-mcp`
- `ai-layer-mcp-use-case`
- `ai-layer-orchestrator`

Expected public hosts when ingress is enabled:

- `api.galust.ai`
- `mcp.galust.ai`

## Local Validation

```bash
helm dependency update charts/galust-ai-layer
helm lint charts/galust-ai-layer
helm template galust-ai-layer charts/galust-ai-layer -n ai-layer
helm template galust-ai-layer charts/galust-ai-layer -n ai-layer --set backend.enabled=false
helm template galust-ai-layer charts/galust-ai-layer -n ai-layer -f examples/galust-ai-layer/values.test.yaml
```

## Troubleshooting

If pods are stuck in `ImagePullBackOff`, check the `ecr-secret` secret and ECR access.

If the backend fails to start, check the `ai-layer-strapi` and `db-ai-layer-strapi` secrets, plus database reachability from the namespace.

If ingress does not work, confirm the ingress controller, DNS records, TLS secret or cert-manager issuer, and rendered ingress hosts.

If URL overrides do not appear in rendered manifests, remember that YAML anchors are not dynamic Helm templates. Render locally with:

```bash
helm template galust-ai-layer charts/galust-ai-layer -n ai-layer -f examples/galust-ai-layer/values.test.yaml
```
