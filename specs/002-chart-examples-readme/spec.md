# Feature Specification: Chart Examples and README Improvements

**Feature Branch**: `002-chart-examples-readme`
**Created**: 2026-03-09
**Status**: Draft
**Input**: User description: "for dasmeta/helm charts improve examples and readme files of each chart"

## Clarifications

### Session 2026-03-09

- Q: Should "each chart" mean only top-level chart directories under `charts/`, or also nested subchart directories? → A: Only top-level chart directories under `charts/`. Nested subcharts are out of scope; document them in the parent chart's README.
- Q: Where should example values files live—standardize or allow either? → A: Standardize on repo-level `examples/<chart-name>/` for all charts. READMEs point to this location.
- Q: For "documents public values," is linking to values.yaml enough or must every value be listed in the README? → A: README MUST link to values.yaml (and its comments) as the source of truth; MAY include a short "key values" subsection for the most important 3–5 options.
- Q: For library/dependency-only charts, same README standard or reduced? → A: Reduced standard: minimal README (one short paragraph: what it is, that it's used as a dependency, link to values.yaml or parent chart).
- Q: Prioritize a subset of charts for MVP or treat all equally? → A: Treat all top-level charts equally; no mandatory implementation order. Success = 100% of top-level charts meet the README/example bar.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consumer can install and configure from docs (Priority: P1)

As a chart consumer, I want each chart to have a clear README and working examples so that I can install and configure the chart without relying on tribal knowledge or guessing values.

**Why this priority**: Enables self-service adoption; reduces support and onboarding time.

**Independent Test**: Pick any chart; follow only its README and example values; complete a valid install or render (helm template) without external help.

**Acceptance Scenarios**:

1. **Given** I have added the Dasmeta Helm repo, **When** I open a chart's README, **Then** I see how to install that chart and where to find or how to use example values.
2. **Given** a chart provides example values, **When** I run helm template (or install) with that example, **Then** it succeeds (no lint/template failure due to the example).
3. **Given** I need to customize configuration, **When** I read the README (and values comments if linked), **Then** I understand which values are public and what they do.

---

### User Story 2 - Consistent documentation quality across charts (Priority: P2)

As a maintainer, I want every chart to meet a minimum documentation standard (README + at least one working example where applicable) so that the repo is consistent and contributors know what to add for new charts.

**Why this priority**: Scales contribution; avoids "some charts documented, some not."

**Independent Test**: Audit all charts; each has a README that describes the chart, install steps, and value documentation (or link to it); charts that support examples have at least one valid example file.

**Acceptance Scenarios**:

1. **Given** any top-level chart under charts/, **When** I check for a README, **Then** it exists and includes a description, install instructions, and reference to the Dasmeta Helm repo.
2. **Given** a chart where examples are applicable, **When** I look for example values, **Then** at least one example file exists and passes helm template (or lint) with that chart.
3. **Given** a chart README, **When** I look for public values documentation, **Then** the README links to values.yaml (and its comments); optionally a short "key values" subsection is present.

---

### Edge Cases

- Charts with no optional features: README still required; a single "minimal" or default example is sufficient.
- Subcharts or dependency-only charts: Reduced README standard (one short paragraph: what it is, dependency use, link to values or parent); examples may be minimal or N/A if not installable standalone.
- Charts requiring cluster-specific or secret configuration: README MUST state what is required (e.g. secrets, CRDs) and how to provide them; examples may use placeholders that are clearly marked and documented.
- Existing charts with no README or broken examples: In scope for this feature; add or fix as part of the improvement pass.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Each **top-level** chart under `charts/<chart-name>/` (direct child of `charts/` only; nested subcharts are out of scope) MUST have a README that describes what the chart does, how to install it (including `helm repo add dasmeta`), and documents public values by linking to `values.yaml` (and its comments) as the source of truth; the README MAY include a short "key values" subsection for the most important 3–5 options. Parent chart READMEs MUST mention nested subcharts where present. **Library or dependency-only charts** (e.g. `type: library`): reduced standard—minimal README (one short paragraph: what it is, that it's used as a dependency, link to values.yaml or parent chart).
- **FR-002**: Each chart SHOULD have one or more example values files that demonstrate a valid configuration; examples MUST live in repo-level `examples/<chart-name>/` and be usable with `helm template` (and `helm lint` where applicable) without breaking the chart. READMEs MUST point to this location.
- **FR-003**: README MUST NOT hardcode environment-specific values (cluster names, tenant IDs); examples MUST use placeholders or safe defaults and document any required substitution.
- **FR-004**: Public values MUST be documented in values.yaml (comments); the README MUST link to values.yaml as the source of truth and MAY list key values (3–5 main options). Per constitution, all configuration is via values and overrides.
- **FR-005**: **Chart version increment**: Whenever any file under a chart directory changes (including `README.md`, `values.yaml`, templates, or other chart assets), the chart's `version` in `Chart.yaml` MUST be incremented. At minimum increment the PATCH segment (semver: MAJOR.MINOR.PATCH). Documentation-only changes (e.g. README only) still require a PATCH bump so that consumers can correlate published chart versions with content changes.

### Key Entities

- **Chart**: A **top-level** directory under `charts/<chart-name>/` (direct child of `charts/`) with Chart.yaml, templates, and values.yaml; has zero or one README and zero or more example values files. Nested subcharts are not counted as separate charts for this feature.
- **README**: Documentation artifact per chart; contains description, install steps, value documentation or reference, and any prerequisites (e.g. CRDs, secrets).
- **Example values file**: A YAML file under repo-level `examples/<chart-name>/` that can be used with `-f` to produce a valid render/install for that chart. README points to this path.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of **top-level** charts under `charts/` have a README that satisfies FR-001 (full standard for application charts; reduced standard for library/dependency-only charts); nested subcharts are excluded.
- **SC-002**: Every chart that has at least one example values file has that example validated (helm template with that file succeeds for that chart).
- **SC-003**: A reviewer can complete a "new user" test for any chart: install or template using only README + example in under 10 minutes without prior knowledge of that chart.
- **SC-004**: No chart README or example introduces environment-specific secrets or cluster names as literal values; placeholders or docs only.

## Assumptions

- "Each chart" means only **top-level** chart directories under `charts/` (e.g. `charts/base/`, `charts/proxysql/`). Nested subcharts are out of scope; the parent chart's README MUST mention and briefly describe nested subcharts. **Library or dependency-only charts** (e.g. `type: library` in Chart.yaml): reduced README standard—one short paragraph (what it is, that it's used as a dependency, link to values.yaml or parent chart).
- Examples MUST live in repo-level `examples/<chart-name>/`; READMEs point to this location. No new or updated examples inside `charts/<chart-name>/` for this feature.
- Improvements are additive (add missing READMEs, add or fix examples); no requirement to remove or rewrite existing adequate documentation.
- No mandatory implementation order: all top-level charts are in scope equally; plan/tasks may order by dependency or convenience, but success is 100% of top-level charts.
