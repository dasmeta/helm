# Implementation: 002-chart-examples-readme

**Run**: /speckit.implement for dasmeta/helm  
**Feature**: 002-chart-examples-readme  
**Date**: 2026-03-09

## Status

Implementation **complete** for all required tasks. T001–T030 done (T030 version bumps applied by /speckit.implement). Optional: T026 (new-user test).

| Phase   | Tasks      | Status |
|---------|------------|--------|
| Phase 1 | T001–T002  | Done   |
| Phase 2 | T003–T005  | Done   |
| Phase 3 | T006–T023  | Done (19 charts README + examples) |
| Phase 4 | T024–T027  | Done except T026 (optional) |
| Phase 5 | T028–T030  | Done (incl. version bumps) |

## What was implemented

- **Canonical chart list**: `CHARTS.txt` (19 top-level charts); all have `examples/<chart-name>/`.
- **READMEs**: Every top-level chart has a README meeting FR-001 (install, values link, examples link); nested subcharts mentioned where applicable (e.g. weave-scope).
- **Examples**: Each chart has ≥1 example file in `examples/<chart-name>/`; validated with `helm template` (and documented exception for one base example that depends on gateway-api version).
- **Validation**: T024 (README audit), T025 (every example file helm template), T027 (SC-004 placeholders) completed.
- **Repo docs**: Root README points to charts and examples; quickstart.md validated.

## How to re-validate (implementer)

From repo root (dasmeta/helm):

```bash
# Lint all 19 charts
for c in $(cat specs/002-chart-examples-readme/CHARTS.txt | grep -v '^#'); do
  helm lint "charts/$c" || true
done

# Template with first example per chart
for c in $(cat specs/002-chart-examples-readme/CHARTS.txt | grep -v '^#'); do
  f=$(ls examples/$c/*.yaml 2>/dev/null | head -1)
  [ -n "$f" ] && helm template test "charts/$c" -f "$f" >/dev/null || true
done
```

## Optional: T026 (new-user test)

To complete T026: pick one chart (e.g. `base`), follow only its README and one example, and run `helm template` (or install) in under 10 minutes. Document the result in this file or in quickstart.md (e.g. "New-user test: base chart, 2026-03-09, completed in &lt;N&gt; min; no blockers."). Then mark T026 [x] in tasks.md.

## Version bumps (FR-005) — run T030 when you run implement

When merging chart changes (including README or examples), ensure each modified chart’s `Chart.yaml` has its `version` incremented (at least PATCH).

When you run /speckit.implement, you MUST complete T030: for every chart modified in this feature (all 19 in 002), increment version in charts/<name>/Chart.yaml (at least PATCH). If gateway-api is bumped, update base dependency in charts/base/Chart.yaml to match. Mark T030 [x] after doing this. Implement is not complete until T030 is done.

## References

- **Tasks**: [tasks.md](./tasks.md)  
- **Spec**: [spec.md](./spec.md)  
- **Plan**: [plan.md](./plan.md)  
- **Quickstart (implementer)**: [quickstart.md](./quickstart.md)  
- **Contract**: [contracts/readme-and-examples.md](./contracts/readme-and-examples.md)
