# Redash

Redash is an optional visualisation provider for the data-analytics platform. The chart deploys the native Redash server, scheduler, and worker topology through aliases of the published `dasmeta/base` chart. It does not provision PostgreSQL, Redis, users, grants, DNS, ingress controller, or runtime secrets.

## Prerequisites

- A PostgreSQL application database and a Redis endpoint, provisioned outside this chart.
- A Kubernetes Secret containing `REDASH_DATABASE_URL`, `REDASH_REDIS_URL`, `REDASH_COOKIE_SECRET`, and `REDASH_SECRET_KEY`.
- An ingress controller and DNS record if public access is enabled.

The first deployment must run Redash's native `create_db` command. The minimal example does this as a server init container before the web server starts. The command uses the same externally managed runtime Secret as the Redash services.

## Install

```bash
helm repo add dasmeta https://dasmeta.github.io/helm
helm upgrade --install redash dasmeta/redash \
  --namespace analytics --create-namespace \
  --version 0.1.0 \
  -f examples/redash/minimal.yaml
```

The referenced Secret is created by the platform secret-management flow. Do not place Redash database, Redis, or cryptographic keys in Helm values.

## Components and key values

| Component | Values key | Native command | Default queues |
| --- | --- | --- | --- |
| Web server | `server` | `server` | — |
| Scheduler | `scheduler` | `scheduler` | — |
| Scheduled worker | `scheduledWorker` | `worker` | `scheduled_queries,schemas` |
| Ad-hoc worker | `adhocWorker` | `worker` | `queries` |
| Default worker | `defaultWorker` | `worker` | `periodic,emails,default` |

Each component has its own `envFrom`, `resources`, `replicaCount`, and scheduling values. Only `server.ingress` exposes a Service by default. The Redash image entrypoint receives the native command through the component's `args` value. Resource names include the Helm release name, so separate releases do not collide in one namespace.

## Validate locally

From the repository root:

```bash
helm template redash charts/redash -f examples/redash/minimal.yaml
```
