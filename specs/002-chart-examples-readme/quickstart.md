# Quickstart: Chart Examples and README Improvements (002)

**Feature**: 002-chart-examples-readme  
**Date**: 2026-03-09

## For consumers (using charts after this feature)

1. Add repo: `helm repo add dasmeta https://dasmeta.github.io/helm && helm repo update`
2. Pick a chart (e.g. `base`): open `charts/base/README.md` for description and install steps.
3. Values: README links to `charts/base/values.yaml` (and comments); optional "key values" subsection.
4. Examples: README points to `examples/base/`; run e.g. `helm template my-release charts/base -f examples/base/basic.yaml` (from repo root).

## For implementers (doing the 002 work)

1. **Audit**: List top-level charts: `ls -1d charts/*/ | sed 's|charts/||;s|/||'` (19 charts).
2. **README**: For each chart, add or update `charts/<name>/README.md` per FR-001 (full or reduced standard); ensure link to values.yaml and, if applicable, to `examples/<name>/`.
3. **Examples**: For each chart, ensure at least one file in `examples/<name>/` that passes `helm template <release> charts/<name> -f examples/<name>/<file>.yaml`; create dir and file if missing.
4. **Validate**: `helm lint charts/<name>` and `helm template test charts/<name> -f examples/<name>/<file>.yaml` (no failures).
5. **Check**: No hardcoded env-specific values in README or examples (SC-004).

## Success (definition of done)

- 100% of top-level charts have a README meeting FR-001.
- Every chart that has an example has that example validated (helm template succeeds).
- New-user test: install or template using only README + example in under 10 minutes.
