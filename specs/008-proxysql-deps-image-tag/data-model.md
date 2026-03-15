# Data Model: 008-proxysql-deps-image-tag

No persistent data store. The feature only touches chart metadata and default values.

## Entities (chart metadata and values)

| Entity | Attributes | Notes |
|--------|------------|--------|
| **ProxySQL chart (Chart.yaml)** | version, appVersion, dependencies[] | version: PATCH bump. dependencies: base (version, alias, repository, condition), base-cronjob (version, alias, repository, condition). |
| **ProxySQL chart (values.yaml)** | proxysql.image.tag | Default image tag; MUST be 3.0.6 to match appVersion. |
| **Dependency (base)** | name, version, repository, alias | version = latest from Helm repo at implementation time (e.g. 0.3.24 from repo). |
| **Dependency (base-cronjob)** | name, version, repository, alias, condition | version = latest from Helm repo at implementation time (e.g. 0.1.38 from repo). |

## Validation rules

- Chart.yaml dependencies: version fields must reference versions that exist in the configured Helm repository.
- values.yaml: `proxysql.image.tag` must equal Chart.yaml `appVersion` (3.0.6).
- Chart version must be incremented (PATCH) after any change.

## State transitions

N/A — no lifecycle; one-time version and value updates.
