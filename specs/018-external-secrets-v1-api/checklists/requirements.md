# Requirements Checklist: External Secrets v1 API Default

**Feature**: `specs/018-external-secrets-v1-api/spec.md`

## Content Quality

- [x] No implementation-only details in user stories
- [x] Consumer value and upgrade risk are clear
- [x] Acceptance scenarios are independently testable
- [x] Scope is bounded to the two charts that generate External Secrets resources

## Requirement Completeness

- [x] New default specified for both charts
- [x] Override behavior specified for both charts
- [x] apiVersion-only guarantee specified, so no consumer values change
- [x] Operator precondition and its apply-time failure mode specified
- [x] Cluster-scoped blast radius of `namespaces-and-docker-auth` called out against the per-release scope of `base`
- [x] Existing suppression guards specified as unchanged for both charts
- [x] Documentation, README table sync, runnable example, and version bumps specified
- [x] `appVersion` handling specified for both charts, including the deliberate asymmetry
