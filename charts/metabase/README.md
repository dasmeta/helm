# Metabase

Metabase is the default visualisation provider for the data-analytics platform. This chart is a thin wrapper around the published `dasmeta/base` chart; it deploys Metabase only and does not create its application database, users, grants, DNS, ingress controller, or secrets.

## Prerequisites

- A PostgreSQL application database and an application user, provisioned outside this chart.
- A Kubernetes Secret containing Metabase runtime configuration. At minimum it must contain `MB_DB_TYPE=postgres` and `MB_DB_CONNECTION_URI`.
- An ingress controller and DNS record if public access is enabled.

## Install

```bash
helm repo add dasmeta https://dasmeta.github.io/helm
helm upgrade --install metabase dasmeta/metabase \
  --namespace analytics --create-namespace \
  --version 0.1.0 \
  -f examples/metabase/minimal.yaml
```

The example references `example-metabase-runtime`; create it through the platform secret-management flow before installing. Do not place credentials in Helm values.

## Key values

All application values are nested under `base` because this chart depends on `dasmeta/base`.

| Key | Purpose |
| --- | --- |
| `base.envFrom` | References the Secret containing `MB_*` runtime settings. |
| `base.ingress` | Enables and configures external access. |
| `base.resources` | Configures Metabase resource requests and limits. |
| `base.fullnameOverride` | Provides a stable service name. |

## Validate locally

From the repository root:

```bash
helm template metabase charts/metabase -f examples/metabase/minimal.yaml
```
