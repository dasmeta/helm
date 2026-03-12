# Contract: README values table (004)

**Feature**: 004-readme-values-table  
**Date**: 2026-03-09

## Table requirement (per top-level chart)

- **Location**: `charts/<chart-name>/README.md`
- **Content**: At least one markdown table with columns **Key**, **Description**, **Default / Example** (or equivalent).
- **Key**: Dotted path into values (e.g. `routerConfig.listen_addr`, `image.repository`).
- **Description**: One-line description of the option.
- **Default / Example**: Literal value, or "example in values.yaml", or "commented out by default", etc.
- **Coverage**: Main public values (at least 3–10 key options, or by section). May link to values.yaml for full list.

## Sync with values.yaml

- When public values in `values.yaml` are added, removed, or changed, the README table MUST be updated in the **same change** (same PR). No drift.

## Reference format

See [charts/spqr-router/README.md](../../../charts/spqr-router/README.md) (e.g. lines 57–62) for the canonical table format.
