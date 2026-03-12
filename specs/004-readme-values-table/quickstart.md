# Quickstart: README values table (004)

**Feature**: 004-readme-values-table  
**Date**: 2026-03-09

## For consumers

- Each chart README now has a table of key values (Key, Description, Default/Example). Use it to scan options before opening values.yaml. Full details and comments remain in `values.yaml`.

## For implementers

1. **Audit**: For each top-level chart, open `charts/<name>/README.md` and `charts/<name>/values.yaml`.
2. **Table**: If README has no Key/Description/Default/Example table, add one. If it has one, check it matches values.yaml (keys exist, no removed keys).
3. **Format**: Use markdown table; columns Key, Description, Default / Example. Key = dotted path (e.g. `image.repository`). Default/Example = value or "example in values.yaml" or "commented out by default".
4. **Scope**: At least 3–10 key options per chart (or one table per section). Link to values.yaml for full list.
5. **Sync**: When you change values.yaml, update the README table in the same commit/PR.

## Reference

- Example table: [charts/spqr-router/README.md](../../charts/spqr-router/README.md) (lines 57–62).
- Constitution: `.specify/memory/constitution.md` (README values table and sync).
