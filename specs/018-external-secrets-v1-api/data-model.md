# Data Model: External Secrets v1 API Default

## BaseExternalSecretsApiVersion

Top-level value on `charts/base` selecting the API version of the generated `ExternalSecret`.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `externalSecretsApiVersion` | string | no | API version of the rendered `ExternalSecret`. Defaults to `external-secrets.io/v1`. Set to `external-secrets.io/v1beta1` for clusters whose operator does not serve `v1`. |

## DockerAuthExternalSecretsApiVersion

Value on `charts/namespaces-and-docker-auth`, nested under the `dockerAuth` feature that owns every External Secrets resource in that chart.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `dockerAuth.externalSecretsApiVersion` | string | no | API version of the rendered `ClusterSecretStore` and `ClusterExternalSecret`. Defaults to `external-secrets.io/v1`. Set to `external-secrets.io/v1beta1` for clusters whose operator does not serve `v1`. |

## ApplicationExternalSecret

One namespaced `ExternalSecret` rendered by `charts/base` when `secretsDefaultEngine` is `ExternalSecrets` and the computed secrets list is non-empty.

Key fields:

- `apiVersion`: from `externalSecretsApiVersion`
- `spec.refreshInterval`: unchanged
- `spec.secretStoreRef`: unchanged, `name` derived from product and env, `kind` from `secretStoreKind`
- `spec.target`: unchanged, `creationPolicy: Owner`
- `spec.data[]`: unchanged, one entry per mapped secret with `remoteRef.key` and `remoteRef.property`

Scope: one resource per release, in the release namespace.

## DockerAuthClusterSecretStore

One `ClusterSecretStore` rendered by `charts/namespaces-and-docker-auth` when `dockerAuth.enabled` is true.

Key fields:

- `apiVersion`: from `dockerAuth.externalSecretsApiVersion`
- `spec.provider.aws.service`: `SecretsManager`, unchanged
- `spec.provider.aws.region`: unchanged
- `spec.provider.aws.auth.jwt.serviceAccountRef`: unchanged

Scope: cluster-wide.

## DockerAuthClusterExternalSecret

One `ClusterExternalSecret` rendered by `charts/namespaces-and-docker-auth` when `dockerAuth.enabled` is true.

Key fields:

- `apiVersion`: from `dockerAuth.externalSecretsApiVersion`
- `spec.namespaceSelector`: unchanged
- `spec.refreshTime`: unchanged
- `spec.externalSecretSpec`: unchanged, including the `dockerconfigjson` target template at `engineVersion: v2` and the per-registry `data[]` entries

Scope: cluster-wide; instantiates a Secret in every matched namespace.
