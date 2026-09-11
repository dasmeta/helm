# Base Chart PodDisruptionBudget Safety Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Status:** COMPLETE. Every step below is checked because the work shipped in
`base` 0.4.0. Kept as the record of what was done and in what order.

**Goal:** Make the `base` chart produce a safe PodDisruptionBudget by default
for multi-replica workloads, and make a drain-blocking budget impossible to
express.

**Architecture:** Named helpers in `_helpers.tpl` compute the effective replica
floor and validate any requested budget. `pdb.yaml` calls the validation helper
unconditionally, before the enabled check, so an invalid configuration cannot
pass by being disabled. Validation aborts the render with Helm's `fail`.

**Tech Stack:** Helm 3.15, `yq` 4.44, `jq` 1.7, bash. No cluster, no cloud
credentials, no Helm unit-test plugin.

**Spec:** `docs/superpowers/specs/2026-08-28-base-chart-pdb-safety-design.md`

## Global Constraints

- **Baseline-first.** The test runner and every case are built and run against
  the *unmodified* chart before any template changes. Each negative case must
  fail at that point; a negative case that already passes is asserting nothing
  and has to be corrected before implementation starts.
- No Helm unit-test plugin. `helm template` plus shell assertions only.
- Numeric comparisons must not degrade to string comparison — `"10"` orders
  before `"2"` as text.
- Services already setting a valid budget must render exactly as they do today.

---

### Task 1: Test harness and case matrix

**Files:** `tests/run.sh`, `tests/base/pdb/*.yaml`

- [x] Write the runner: one values file per case, positive cases assert on
      rendered output, negative cases assert non-zero exit plus a message substring
- [x] Write 10 positive cases covering floors 1/2/3, autoscaling and static,
      explicit valid budgets in both forms, percentages, string-typed floors,
      and an explicitly disabled budget
- [x] Write 6 negative cases: `minAvailable` equal to and above the floor,
      `maxUnavailable: 0`, both fields set, a percentage rounding to zero, and an
      explicitly enabled budget at floor 1

### Task 2: Capture the baseline (BLOCKING GATE)

- [x] Run the full suite against the unmodified chart
- [x] Record results in the spec package and report them honestly

**Result: 2 passed, 14 failed of 16.** All 6 negative cases failed as required,
so none is vacuous. Of the 2 passes, `explicitly-disabled` passed for the right
reason; `floor-1-no-pdb` passed for the **wrong** reason — no budget renders
because budgets are off entirely, not because floor logic exists. Recorded as
non-discriminating at baseline rather than counted as evidence.

### Task 3: Replica floor and validation helpers

**Files:** `charts/base/templates/_helpers.tpl`

- [x] `base.pdb.floor` — autoscaling minimum when enabled, else replica count,
      coerced with `int64` before any comparison
- [x] `base.pdb.permitted` — permitted evictions at the floor, following
      Kubernetes rounding: `minAvailable` up, `maxUnavailable` down
- [x] `base.pdb.validate` — refuses zero-eviction budgets, both-fields-set, and
      explicit budgets below floor 2, naming value, floor and accepted range

### Task 4: Wire the guard into the template

**Files:** `charts/base/templates/pdb.yaml`

- [x] Call `base.pdb.validate` unconditionally, **before** the enabled check
- [x] Render by default when the floor is >= 2, defaulting to `maxUnavailable: 1`
- [x] Support `minAvailable` and `maxUnavailable`, mutually exclusive
- [x] Run the suite — 16 passed, 0 failed

### Task 5: Correct the examples

**Files:** `examples/base/*.yaml` (18 files)

- [x] Remove the redundant `pdb:` blocks so the safe default demonstrates itself
- [x] Add `with-pdb-tuned.yaml` showing deliberate budget tuning
- [x] Render all 31 example files as a regression check

### Task 6: Values, docs and release

**Files:** `charts/base/values.yaml`, `charts/base/README.md`,
`charts/base/Chart.yaml`, `charts/base/templates/deployment.yaml`

- [x] Document `pdb` and `terminationGracePeriodSeconds` in values.yaml
- [x] Remove the dead `| default 30` on `terminationGracePeriodSeconds`
- [x] Sync the README values table and add migration notes for the breaking change
- [x] Bump chart 0.3.33 -> 0.4.0

### Task 7: Gate it in CI

**Files:** `.github/workflows/chart-tests.yaml`

- [x] New gating workflow running `helm lint`, the case suite, and the example
      render sweep. The existing pre-commit workflow is `continue-on-error` and
      does not gate, so it could not serve this purpose.

---

## Notes from execution

The first implementation put `maxUnavailable: 1` as a literal default in
`values.yaml`. Because Helm merges values, that default survived alongside any
`minAvailable` a service supplied, so every service using `minAvailable` tripped
the mutual-exclusion guard. Six cases failed and pinned the cause immediately —
which is the argument for building the matrix before the implementation.
