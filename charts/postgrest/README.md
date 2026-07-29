# PostgREST

PostgREST exposes the governed analytics schema through a REST API. This chart deploys PostgREST only; it does not provision PostgreSQL, roles, grants, schema migrations, DNS, ingress controller, or runtime secrets.

## Prerequisites

- A PostgreSQL analytics database with a dedicated API role and least-privilege grants.
- A Kubernetes Secret with PostgREST configuration, including `PGRST_DB_URI`, `PGRST_DB_SCHEMAS`, `PGRST_DB_ANON_ROLE`, and `PGRST_JWT_SECRET` when JWT authentication is enabled.
- An ingress controller and DNS record if the API is exposed externally.

## Install

```bash
helm repo add dasmeta https://dasmeta.github.io/helm
helm upgrade --install postgrest dasmeta/postgrest \
  --namespace analytics --create-namespace \
  --version 0.1.0 \
  -f examples/postgrest/minimal.yaml
```

The referenced Secret is created by the platform secret-management flow. Keep database credentials and JWT keys out of Helm values.

## Key values

All application values are nested under `base` because this chart depends on `dasmeta/base`.

| Key | Purpose |
| --- | --- |
| `base.envFrom` | References the Secret containing `PGRST_*` runtime settings. |
| `base.ingress` | Enables and configures API exposure. |
| `base.resources` | Configures PostgREST resource requests and limits. |
| `base.fullnameOverride` | Provides a stable internal service name. |

## Validate locally

From the repository root:

```bash
helm template postgrest charts/postgrest -f examples/postgrest/minimal.yaml
```
