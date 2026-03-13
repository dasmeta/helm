# Contract: ProxySQL chart default values (008)

**Scope:** Default values that must hold after this feature.

| Key | Type | Required default | Notes |
|-----|------|-------------------|--------|
| `proxysql.image.tag` | string | `"3.0.6"` | MUST match Chart.yaml appVersion (constitution). |

Dependency versions (base, base-cronjob) are defined in Chart.yaml and resolved at install time from the Helm repo; no values contract for dependency versions.
