# Contract: Chart Consumption (dasmeta/helm)

**Feature**: 001-spec-workflow  
**Date**: 2026-03-09

## Repository contract

- **Add repo**: `helm repo add dasmeta https://dasmeta.github.io/helm`
- **Charts**: All charts live under `charts/<chart-name>/`. One chart per directory.
- **Install**: `helm upgrade --install <release> dasmeta/<chart-name> -f values-override.yaml` (or `--set` overrides).
- **Dependencies**: Charts may depend on other charts in the same repo; repository URL in Chart.yaml is `https://dasmeta.github.io/helm`.

## Values contract (per chart)

- Configuration is **only** via:
  - Chart `values.yaml` (defaults)
  - `-f <file>` and `--set` / `--set-file` at install/upgrade
- Templates MUST NOT hardcode environment-specific values (cluster name, tenant ID, etc.).
- All public keys MUST be documented in the chart README and/or comments in `values.yaml`.

## Validation contract

- Before merge, every chart MUST pass:
  - `helm lint charts/<chart-name>`
  - `helm template <release> charts/<chart-name>` (or equivalent) with default values.
- CI SHOULD enforce these checks.
