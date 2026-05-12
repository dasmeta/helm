# Research: Zero Trust Mesh Empty Default Allow Rules

## Decision: Set active zero-trust-mesh `allowTo` default to `[]`

**Rationale**: Existing templates already wrap service, host, and IP resources in `.Values.allowTo` conditionals. Emptying the active list removes sample resources without changing template behavior.

**Alternatives considered**:

- Add new template guards: rejected because `.Values.allowTo` is already the correct guard.
- Remove examples entirely from `values.yaml`: rejected because consumers still need discoverable rule shapes.

## Decision: Add base parent override `zeroTrustMesh.allowTo: []`

**Rationale**: `charts/base` currently vendors `zero-trust-mesh-0.1.0.tgz`, so changing the source chart values alone does not affect renders from base. A parent value under the dependency alias overrides the packaged subchart default.

**Alternatives considered**:

- Repackage the subchart immediately: rejected for this change because the parent override fixes current base renders without changing dependency packaging.
- Rely on `zeroTrustMesh.enabled=false`: insufficient because the reported issue happens when consumers enable the subchart from base.

## Decision: Use focused shell render assertions

**Rationale**: The bug is visible in rendered manifests. Small shell assertions catch the exact accidental resources and fit the repository's existing Helm render validation style.

**Alternatives considered**:

- Snapshot the entire Helm output: rejected as too brittle for chart metadata and unrelated resource ordering.
- Add template-unit framework dependency: rejected as unnecessary for this small values contract regression.
