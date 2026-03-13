# Feature Specification: README values table (Key / Description / Default or Example)

**Feature Branch**: `004-readme-values-table`  
**Created**: 2026-03-09  
**Status**: Draft  
**Input**: Fix/update charts README.md to have a Key / Default / Example / Description table of values.yaml props (similar to spqr-router README lines 57–62); add to constitution that values.yaml and this table must be kept in sync.

## Clarifications

- **Table format**: Same as spqr-router example: markdown table with columns **Key**, **Description**, **Default / Example**. Key = dotted path (e.g. `routerConfig.listen_addr`); Description = one line; Default/Example = value or "example in values.yaml" / "commented out by default".
- **Scope**: Top-level charts only (`charts/<chart-name>/`). Per chart: README MUST include at least one such table covering the main public values from that chart's `values.yaml`. Charts with many values MAY have one table for "key options" (3–10 rows) and link to values.yaml for the full list; or multiple tables by section (e.g. image, service, routerConfig).
- **Sync rule**: Constitution now requires: when values are added/removed/changed in `values.yaml`, the README table MUST be updated in the same change. This feature adds the table (or aligns existing tables) so all charts meet the standard; ongoing sync is a process requirement.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consumer can scan options in the README (Priority: P1)

As a chart consumer, I want each chart README to include a table of key values (Key, Description, Default/Example) so I can quickly see what to configure without opening values.yaml first.

**Why this priority**: Aligns with constitution; reduces back-and-forth between README and values.yaml.

**Independent Test**: Open any chart README; find a markdown table with columns Key, Description, and Default/Example (or equivalent) that documents options from that chart's values.yaml.

**Acceptance Scenarios**:

1. **Given** a top-level chart under `charts/`, **When** I open its README, **Then** I see at least one table with Key, Description, and Default/Example (or Default / Example) that reflects options in `values.yaml`.
2. **Given** the table lists a key (e.g. `routerConfig.listen_addr`), **When** I check `values.yaml`, **Then** that key exists (or is documented as optional/example elsewhere) and the table is not stale.
3. **Given** a chart with few public values, **When** the README has a table, **Then** it covers the main values (at least the 3–5 most important or all if ≤10).

### User Story 2 - Values and README table stay in sync (Priority: P2)

As a maintainer, I want the constitution to require that the README values table and values.yaml be updated together so that docs do not drift.

**Why this priority**: Prevents outdated README tables after values change.

**Independent Test**: Constitution includes a rule that README table and values.yaml must be kept in sync (same change/PR when values change).

**Acceptance Scenarios**:

1. **Given** the constitution, **When** I look for "values" or "README table", **Then** there is an explicit requirement that the README table and values.yaml be kept in sync.
2. **Given** a PR that changes values.yaml, **When** I review, **Then** the README table is updated in the same PR (or the spec allows a follow-up task to update it, with a tracking issue).

## Requirements *(mandatory)*

- **FR-001**: Each top-level chart README MUST contain at least one markdown table with columns **Key**, **Description**, **Default / Example** (or equivalent), documenting key public values from that chart's `values.yaml`. Format follows the spqr-router example (e.g. Key = dotted path, Description = short text, Default/Example = value or reference).
- **FR-002**: The README table(s) and `values.yaml` MUST be kept in sync: any change to public values in `values.yaml` MUST be reflected in the README table in the same change (or same PR). This is now in the constitution.
- **FR-003**: Charts that already have a key-values subsection or table (e.g. spqr-router, pgcat) MUST be audited for consistency with values.yaml; add or fix tables where missing or stale. Charts with no table MUST get one (at least key options, 3–10 rows or by section).

## Success Criteria

- Constitution updated: "README values table and sync with values.yaml" rule present.
- 100% of top-level charts have a README table (Key, Description, Default/Example) that reflects their values.yaml.
- No chart README has a table that references non-existent or removed keys without a note.

## Assumptions

- Top-level charts only; nested subcharts are out of scope (parent README can mention subchart options or link to subchart values).
- Table can be "key options" (3–10 rows) with link to values.yaml for full list; or full list if chart has few values.
- Existing tables (e.g. spqr-router) are the reference format; other charts may use one table or multiple tables per section.
