# Research: External Secrets v1 API Default

## Decision: Move both charts to `external-secrets.io/v1`

- **Decision**: Default the generated External Secrets resources to the stable `external-secrets.io/v1`.
- **Rationale**: `v1beta1` is deprecated. The operator releases installed by the dasmeta EKS module serve `v1`, and the sibling Terraform work for this change set already renders `v1` — `dasmeta/terraform-any-shared//modules/external-secret` emits `external-secrets.io/v1`, and the EKS module's external-secret example pins `external_secrets_api_version = "external-secrets.io/v1"`. Leaving the charts on `v1beta1` would make the Helm path the only one still producing deprecated resources.
- **Alternatives considered**:
  - Wait for the operator to drop `v1beta1`: rejected, because the deprecation is already in effect and the charts would then have to change under time pressure rather than behind an override.
  - Detect the served version at render time: rejected. Helm has no reliable, offline way to do this, and `lookup` returns nothing during `helm template` or a dry run, so the result would differ between plan and apply.

## Decision: The change is apiVersion-only

- **Decision**: Change only the `apiVersion` of the rendered resources; leave every spec field where it is.
- **Rationale**: The `v1` promotion of these kinds did not restructure the spec fields these charts use. `charts/base` renders `refreshInterval`, `secretStoreRef`, `target.creationPolicy` and `data[].remoteRef`; `charts/namespaces-and-docker-auth` renders `namespaceSelector`, `refreshTime`, and an `externalSecretSpec` carrying `secretStoreRef`, a `target.template` with `engineVersion: v2`, and `data[].remoteRef`. All are present unchanged in `v1`.
- **Consequence**: No consumer values change, and the rendered diff for an existing release is a single line per resource.

## Decision: Add a values-driven override to `namespaces-and-docker-auth`

- **Decision**: Introduce `dockerAuth.externalSecretsApiVersion`, defaulting to `external-secrets.io/v1`.
- **Rationale**: The two templates hardcoded `v1beta1`, which violates the Values Contract principle and left a cluster on a `v1`-only operator with no supported path. `charts/base` already had exactly this escape hatch, so mirroring it keeps the two charts' consumer stories aligned.
- **Placement**: Nested under `dockerAuth` rather than top level, because every External Secrets resource in this chart is produced by the `dockerAuth` feature and is already gated by `dockerAuth.enabled`. A top-level key would imply a scope the chart does not have.
- **Alternatives considered**:
  - Swap the hardcoded string without adding a value: rejected; it would leave lagging clusters stranded on the previous chart version.
  - Share one value with `charts/base`: rejected; the charts are independent and are not always installed together.

## Decision: The API version a cluster accepts is an operator property

- **Decision**: Treat the operator's served versions as a precondition, documented in the release note, rather than something the chart can negotiate.
- **Rationale**: If the operator does not serve `v1`, the API server rejects the resource at apply time. This surfaces as a failed release rather than silent drift, which is the preferable failure mode, but it must be called out so an operator upgrade is sequenced first.
- **Blast radius note**: `charts/base` produces one namespaced `ExternalSecret` per service, so exposure is per release. `charts/namespaces-and-docker-auth` produces cluster-scoped resources, so a single release changes registry-credential delivery for every matched namespace at once.

## Compatibility Notes

- `charts/base`: `externalSecretsApiVersion` already existed and is still honoured when set explicitly; only its default moves.
- `charts/namespaces-and-docker-auth`: `dockerAuth.externalSecretsApiVersion` is new and defaults to `v1`; setting it to `external-secrets.io/v1beta1` restores the previous rendered output byte for byte.
- `charts/base` suppression guards are untouched: `secretsDefaultEngine` must be `ExternalSecrets` and the computed secrets list must be non-empty, otherwise no resource renders.
- `charts/namespaces-and-docker-auth` suppression is untouched: `dockerAuth.enabled: false` renders neither cluster-scoped resource.
