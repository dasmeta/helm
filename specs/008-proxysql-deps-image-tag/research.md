# Research: 008-proxysql-deps-image-tag

## Dependency version resolution ("latest from Helm repo at implementation time")

**Decision:** Target versions for base and base-cronjob are not pinned in the spec. At implementation time, the implementer MUST obtain the latest available versions from the configured Helm repository (https://dasmeta.github.io/helm) and set those in the proxysql chart’s Chart.yaml.

**Rationale:** Clarification chose "leave to plan — use latest from Helm repo at implementation time." This keeps the spec stable while allowing the chart to track current releases without a spec change each time base or base-cronjob is published.

**How to resolve at implement time:**

1. **Option A (recommended):** Use the version numbers from this repository’s `charts/base/Chart.yaml` and `charts/base-cronjob/Chart.yaml` (they reflect the current chart versions that would be published to the Helm repo). At plan date: base 0.3.24, base-cronjob 0.1.38.
2. **Option B:** Run `helm repo update` and inspect the repo index (or run `helm show chart dasmeta/base` and `helm show chart dasmeta/base-cronjob` after `helm repo add dasmeta https://dasmeta.github.io/helm`) to read the latest version from the remote index.

**Alternatives considered:** Pinning versions in the spec was rejected in clarification (user chose B: leave to plan). Using only Option B (remote index) is valid but Option A is simpler when working in the same repo.

## Image tag and appVersion alignment

**Decision:** Set `proxysql.image.tag` in `values.yaml` to `3.0.6` so the default image matches the chart’s `appVersion` (already 3.0.6 in Chart.yaml).

**Rationale:** Constitution requires app version and default image tag to match; current values have tag 3.0.5.

**Alternatives considered:** None; single source of truth (appVersion) already set.
