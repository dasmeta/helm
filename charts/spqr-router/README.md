# SPQR Router Helm Chart

This chart deploys the [Stateless Postgres Query Router (SPQR)](https://github.com/pg-sharding/spqr) router component using the shared `dasmeta/base` chart as a dependency.  
It is intended to be published together with the other charts in this repository and to be used as an easy way to run `pgsharding/spqr-router` in Kubernetes.

The Docker image used by default is [`pgsharding/spqr-router`](https://hub.docker.com/r/pgsharding/spqr-router).

## Requirements

- Kubernetes 1.18+
- Helm 3.7.1+

## Installation

Add the dasmeta repository and install the chart:

```bash
helm repo add dasmeta https://dasmeta.github.io/helm
helm repo update

helm upgrade --install spqr-router dasmeta/spqr-router \
  --namespace default \
  -f values.yaml
```

## Configuration

This chart is a thin wrapper around the `base` chart:

- **SPQR router–specific configuration** lives at the **root** in `routerConfig` and is rendered into a `ConfigMap` (`router.yaml`) consumed by the router.
- **Pod / service / lifecycle settings** for the router are configured under the `spqr` key and passed to the `base` dependency via its alias.
- For all non–SPQR-specific options (ingress, HPA, topology spread, external secrets, rolloutStrategy, etc.) refer to the `base` chart documentation in `charts/base/README.md`.

### Important `spqr` values (pod & service)

| Key                      | Description                                              | Default                    |
| ------------------------ | -------------------------------------------------------- | -------------------------- |
| `spqr.image.repository`  | Container image repository                               | `pgsharding/spqr-router`   |
| `spqr.image.tag`         | Container image tag (SPQR Router version)               | `2.8.0`                    |
| `spqr.replicaCount`      | Number of router replicas                               | `1`                        |
| `spqr.containerPort`     | Container port where router listens                     | `7432`                     |
| `spqr.service.port`      | Service port                                            | `7432`                     |
| `spqr.resources`         | Resource requests/limits for the SPQR router container  | see `values.yaml`          |
| `spqr.livenessProbe`     | Liveness probe configuration                            | TCP check on port `7432`   |
| `spqr.readinessProbe`    | Readiness probe configuration                           | TCP check on port `7432`   |
| `spqr.volumes`           | Volume mount wiring the generated `router.yaml`         | mounts at `/config/router.yaml` |
| `spqr.extraEnv`          | Extra environment variables for the router              | points to config file path |

You can also set any other `base`-supported fields (e.g. `ingress`, `autoscaling`, `topologySpreadConstraints`) under `spqr` if you need them.

### `routerConfig` – SPQR router configuration

The `routerConfig` map is rendered directly to `router.yaml` via the chart’s ConfigMap template and is the primary place to define SPQR behaviour.

| Key                          | Description                                              | Default / Example       |
| ---------------------------- | -------------------------------------------------------- | ----------------------- |
| `routerConfig.listen_addr`   | Address where router listens for Postgres connections    | `"0.0.0.0:7432"`        |
| `routerConfig.admin_addr`    | (Optional) admin / management endpoint                   | commented out by default |
| `routerConfig.shards`        | List of shards and backend Postgres connection info      | example in `values.yaml` |
| `routerConfig.coordinator`   | (Optional) coordinator connection settings               | example in `values.full.yaml` |

See the upstream SPQR documentation at [`https://github.com/pg-sharding/spqr`](https://github.com/pg-sharding/spqr) for all supported configuration fields.

### Example: basic router deployment

Minimal values file (see also `examples/base/spqr-basic.values.yaml` in this repo):

```yaml
spqr:
  image:
    repository: pgsharding/spqr-router
    tag: "2.8.0"

  service:
    type: ClusterIP
    port: 7432
```

Install with:

```bash
helm upgrade --install spqr-router dasmeta/spqr-router -f spqr-basic.values.yaml
```

### Example: router with configuration defined in `values.yaml`

SPQR is typically configured via a YAML file passed to the router. With this chart the configuration is delivered via `routerConfig` and rendered into `router.yaml` which is mounted into the router container:

```yaml
spqr:
  replicaCount: 2
  image:
    repository: pgsharding/spqr-router
    tag: "2.8.0"
  service:
    port: 7432

routerConfig:
  listen_addr: "0.0.0.0:7432"
  admin_addr: "0.0.0.0:7433"
  # shards:
  #   - name: shard1
  #     db:
  #       host: "postgres-1"
  #       port: 5432
  #       user: "spqr"
  #       password: "spqr"
```

Install:

```bash
helm upgrade --install spqr-router dasmeta/spqr-router -f spqr-with-config.values.yaml
```

## Notes

- This chart only provides the router component. You are expected to provision PostgreSQL instances / shards and SPQR coordinator/balancer components separately according to the official SPQR documentation at `https://github.com/pg-sharding/spqr`.


