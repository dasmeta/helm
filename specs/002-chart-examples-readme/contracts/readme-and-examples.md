# Contract: README and Examples per Chart (002 feature)

**Feature**: 002-chart-examples-readme  
**Date**: 2026-03-09

## README contract (per top-level chart)

- **Path**: `charts/<chart-name>/README.md`
- **Full standard** (application charts): MUST contain description, install steps (including `helm repo add dasmeta`), link to `values.yaml` (and comments) for public values; MUST contain a table of key values with columns **Key**, **Description**, **Default / Example** (per constitution; see 004 spec). If the chart has nested subcharts, MUST mention and briefly describe them. README table and values.yaml MUST be kept in sync (same change when values change).
- **Reduced standard** (library/dependency-only): One short paragraph: what it is, that it's used as a dependency, link to values.yaml or parent chart.
- **No**: Hardcoded cluster names, tenant IDs, or literal secrets.

## Examples contract (per top-level chart)

- **Path**: `examples/<chart-name>/*.yaml` (repo root)
- **Top line**: MUST start with a comment line showing the command to run the example from repo root, e.g. `# helm diff upgrade --install -n localhost <release> ./charts/<chart-name>/ -f ./examples/<chart-name>/<file>.yaml`. New or edited examples MUST include this line so consumers can run or diff without reading the README.
- **Content**: YAML values overrides only; usable as `helm template <release> charts/<chart-name> -f examples/<chart-name>/<file>.yaml`
- **Validation**: Each example file MUST pass `helm template` (and `helm lint` where applicable) with that chart.
- **No**: Environment-specific literals; use placeholders or safe defaults and document substitution in README.

## README → examples link

- README MUST point to the examples location: `examples/<chart-name>/` (and optionally list file names).

## Chart version increment (per chart)

- On **any** change under the chart directory (README.md, values.yaml, templates, or any other file), increment the chart's `version` in `Chart.yaml` (at least PATCH: MAJOR.MINOR.**PATCH**).
- Documentation-only changes (e.g. README only) still require a version bump so published chart versions reflect all content changes.
