# Tasks: External Secrets v1 API Default

**Feature**: `specs/018-external-secrets-v1-api/spec.md`  
**Plan**: `specs/018-external-secrets-v1-api/plan.md`

## Phase 1: Research

- [x] **T001** Confirm `ExternalSecret`, `ClusterSecretStore` and `ClusterExternalSecret` are all served under `external-secrets.io/v1`.
- [x] **T002** Confirm every spec field rendered by both charts exists unchanged in `v1`, including `provider.aws.auth.jwt.serviceAccountRef` and the `externalSecretSpec` template block.
- [x] **T003** Record decisions, placement of the new value, and compatibility notes in `research.md`.

## Phase 2: `charts/base`

- [x] **T010** Change the `externalSecretsApiVersion` default in `charts/base/values.yaml` to `external-secrets.io/v1` and rewrite the trailing comment to describe the override rather than the old default.
- [x] **T011** Confirm `charts/base/templates/external-secrets.yaml` needs no edit; it already renders the value.
- [x] **T012** Add an `externalSecretsApiVersion` row to the key values table in `charts/base/README.md`.
- [x] **T013** Add a `0.3.32` entry under **release important notes** in `charts/base/README.md`, covering the API move, the apiVersion-only nature of the change, and the operator requirement.

## Phase 3: `charts/namespaces-and-docker-auth`

- [x] **T020** Add `dockerAuth.externalSecretsApiVersion` to `charts/namespaces-and-docker-auth/values.yaml`, defaulting to `external-secrets.io/v1`, with a comment describing the override.
- [x] **T021** Render `apiVersion` from that value in `templates/dockerhub-auth.cluster-secret-store.yaml`.
- [x] **T022** Render `apiVersion` from that value in `templates/dockerhub-auth.cluster-external-secrets.yaml`.
- [x] **T023** Add a row for the new value to the key values table in `charts/namespaces-and-docker-auth/README.md`.
- [x] **T024** Add `examples/namespaces-and-docker-auth/docker-auth-api-version.yaml` demonstrating the override, with the required top-line runnable command comment.

## Phase 4: Validation

- [x] **T030** `helm lint ./charts/base ./charts/namespaces-and-docker-auth` reports 0 failed charts.
- [x] **T031** Base default render emits `apiVersion: external-secrets.io/v1` with an otherwise unchanged spec.
- [x] **T032** Base override render emits `external-secrets.io/v1beta1`.
- [x] **T033** Base suppression guards still render nothing for an empty `secrets` list.
- [x] **T034** Docker auth default render emits `external-secrets.io/v1` for both cluster-scoped resources.
- [x] **T035** New example renders both resources on `external-secrets.io/v1beta1`.
- [x] **T036** `dockerAuth.enabled=false` renders neither cluster-scoped resource.
- [x] **T037** Existing examples for both charts render without error (regression).

## Phase 5: Release

- [x] **T040** Bump `charts/base` `version` to `0.3.32`.
- [x] **T041** Bump `charts/base` `appVersion` to `"0.3.32"`, keeping it in step with the chart version per that chart's practice.
- [x] **T042** Bump `charts/namespaces-and-docker-auth` `version` to `0.1.3`. Its `appVersion` stays at `"0.1.0"`: it was already out of step before this feature and re-syncing it is a separate decision.
- [x] **T043** Point `.specify/feature.json` at `specs/018-external-secrets-v1-api`.
