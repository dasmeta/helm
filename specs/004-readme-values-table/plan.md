# Implementation Plan: README values table (Key / Description / Default or Example)

**Branch**: `004-readme-values-table` | **Date**: 2026-03-09 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-readme-values-table/spec.md`

## Summary

Add or update each top-level chart README so it contains at least one markdown table with columns **Key**, **Description**, **Default / Example** documenting key public values from that chart's `values.yaml`. Format follows the spqr-router example. Constitution already updated to require this table and that it be kept in sync with values.yaml. Technical approach: audit all 19 charts for existing tables; add table where missing; align existing tables with values.yaml where stale.

## Technical Context

**Language/Version**: Markdown (READMEs), YAML (values.yaml)
**Primary Dependencies**: None (docs only)
**Storage**: N/A
**Testing**: Manual review; table keys should exist in values.yaml (or be documented as optional/example)
**Target Platform**: Humans reading READMEs
**Project Type**: helm-chart-repository (documentation)
**Constraints**: Top-level charts only; table format: Key (dotted path), Description, Default/Example; sync with values.yaml in same change when values change
**Scale/Scope**: 19 top-level charts (same list as 002)

## Constitution Check

| Principle | Gate | Status |
|-----------|------|--------|
| README values table | Each chart README MUST have table (Key, Description, Default/Example); table and values.yaml MUST be kept in sync | PASS (constitution updated in specify) |
| Chart-First / Values Contract | No chart code change; only README and constitution | PASS |

## Project Structure

```text
specs/004-readme-values-table/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md

charts/<name>/README.md   # Add or update values table in each
```

**Structure Decision**: Same repo layout as 002. Only README files under `charts/<name>/` are modified; reference chart list from CHARTS.txt or 002.
