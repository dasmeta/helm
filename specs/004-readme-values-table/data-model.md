# Data Model: README values table (004)

**Feature**: 004-readme-values-table  
**Date**: 2026-03-09

## Entities

### Chart README (per top-level chart)

| Attribute | Description | Validation |
|-----------|-------------|------------|
| path | `charts/<name>/README.md` | Must exist (per 002) |
| values table | At least one markdown table | Columns: Key, Description, Default / Example (or equivalent) |
| table rows | Rows document key public values | Keys match or reference values in `values.yaml`; no stale keys |

### Values table (structure)

| Column | Description | Example |
|--------|-------------|---------|
| Key | Dotted path into values | `routerConfig.listen_addr`, `image.repository` |
| Description | One-line description | "Address where router listens for Postgres connections" |
| Default / Example | Value or reference | `"0.0.0.0:7432"`, "example in values.yaml", "commented out by default" |

### Sync rule (constitution)

- When `values.yaml` is changed (add/remove/change public value), README table MUST be updated in the same change (same PR).
