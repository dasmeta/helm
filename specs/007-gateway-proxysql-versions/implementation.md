# Implementation Summary: 007-gateway-proxysql-versions

**Feature**: Base chart gateway-api 0.1.3 + ProxySQL appVersion 3.0.6  
**Branch**: `007-gateway-proxysql-versions`  
**Completed**: 2025-03-13

## Changes

### Base chart (`charts/base/`)
- **Chart.yaml**: gateway-api dependency `0.1.2` → `0.1.3`; chart `version` and `appVersion` `0.3.23` → `0.3.24`.
- **Chart.lock**: Updated via `helm dependency update charts/base`; gateway-api 0.1.3.
- **charts/**: Refreshed dependency artifact (gateway-api tgz).

### ProxySQL chart (`charts/proxysql/`)
- **Chart.yaml**: `appVersion` `3.0.5` → `3.0.6`; chart `version` `1.2.2` → `1.2.3`.

## Validation

- `helm lint charts/base charts/proxysql` — passed.
- `helm template test-base charts/base` — passed.
- `helm template test-proxysql charts/proxysql` — passed.

## Re-validate (from repo root)

```bash
helm lint charts/base charts/proxysql
helm template test-base charts/base
helm template test-proxysql charts/proxysql
```

## Tasks

T001–T014 marked [x]. Chart changes committed (base + proxysql in one commit on this run). T015 (optional breaking-change note) skipped.
