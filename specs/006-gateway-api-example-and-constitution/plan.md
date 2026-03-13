# Gateway API infrastructure.parameters Example + Constitution “Examples for New Abilities” — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a runnable example under `examples/gateway-api/` that demonstrates `gateways[].infrastructure.parameters`, and add a constitution rule requiring an example for any new public configuration/behavior so future abilities (e.g. used from dasmeta/base or elsewhere) are always documented with an example.

**Architecture:** One new example YAML file shows infrastructure.parameters (object and string values); constitution gets one new bullet under Additional Constraints. No chart code changes; chart version is not bumped (only examples + constitution).

**Tech Stack:** YAML (values override), Helm 3, Markdown (constitution).

**Context:** Clarification (Option A): require an example whenever a change adds new public configuration surface or behavior. This plan implements that for the existing `gateways[].infrastructure.parameters` feature and encodes the rule in the constitution.

---

## Summary

1. Create `examples/gateway-api/infrastructure-parameters.yaml` with top-line command comment and values that set `gateways[].infrastructure.parameters` (e.g. `service`, `deployment` as object and string).
2. Update `.specify/memory/constitution.md`: add bullet **Examples for new abilities** under Additional Constraints; bump constitution version (MINOR) and Last Amended date.
3. Validate: `helm template` and `helm lint` with the new example; confirm constitution reads correctly.

## File Structure

**Created:**
- `examples/gateway-api/infrastructure-parameters.yaml` — Example values demonstrating `gateways[].infrastructure.parameters` (chart-generated ConfigMap + parametersRef).

**Modified:**
- `.specify/memory/constitution.md` — New constraint under Additional Constraints; version and date.

**Not modified:** Chart code or `Chart.yaml` (example-only + constitution; no chart PATCH bump required for example-only adds per typical practice, unless repo policy says otherwise).

---

## Task 1: Add example file for infrastructure.parameters

**Files:** Create: `examples/gateway-api/infrastructure-parameters.yaml`

- [ ] **Step 1: Add top-line command comment**

Per constitution, the first line MUST be a comment with the runnable command from repo root, e.g.:

```yaml
# helm template <release> ./charts/gateway-api/ -f ./examples/gateway-api/infrastructure-parameters.yaml
```

(or `helm diff upgrade --install -n <namespace> <release> ./charts/gateway-api/ -f ./examples/gateway-api/infrastructure-parameters.yaml` to match existing examples).

- [ ] **Step 2: Add values demonstrating infrastructure.parameters**

Include at least one gateway with `infrastructure.parameters` with both an object value (e.g. `service`) and a string value (e.g. `deployment`) so the example exercises the full behavior (ConfigMap generation and parametersRef). Example body:

```yaml
# Example: gateways[].infrastructure.parameters — chart creates a ConfigMap and sets parametersRef.
gateways:
  - name: main
    namespace: istio-system
    listeners:
      - port: 80
        protocol: HTTP
    infrastructure:
      parameters:
        service:
          type: LoadBalancer
        deployment: "replicas: 2"
```

- [ ] **Step 3: Validate**

Run from repo root:  
`helm template test ./charts/gateway-api/ -f ./examples/gateway-api/infrastructure-parameters.yaml`  
Expected: One ConfigMap (e.g. `test-infra-main`) and one Gateway with `spec.infrastructure.parametersRef` pointing to it.

Run: `helm lint ./charts/gateway-api/ -f ./examples/gateway-api/infrastructure-parameters.yaml`  
Expected: 0 chart(s) failed.

- [ ] **Step 4: Commit**

```bash
git add examples/gateway-api/infrastructure-parameters.yaml
git commit -m "docs(gateway-api): add example for infrastructure.parameters"
```

---

## Task 2: Update constitution — Examples for new abilities

**Files:** Modify: `.specify/memory/constitution.md`

- [ ] **Step 1: Add new bullet under Additional Constraints**

After the bullet **README values table and sync with values.yaml** (around line 44), add:

```markdown
- **Examples for new abilities**: Whenever a change introduces new public configuration surface or behavior for consumers (e.g. a new top-level or major nested value, support for a new CRD/template, or a new usage mode of the chart), at least one example values file MUST be added or updated under `examples/<chart-name>/` to demonstrate that ability. Rationale: every major new ability is paired with a concrete, runnable example.
```


- [ ] **Step 2: Bump constitution version and date**

Per Governance: MINOR bump for new material guidance. Update the footer line, e.g.:

- Version: `1.2.0` → `1.3.0`
- Last Amended: set to the date of the change (e.g. `2026-03-13`).

- [ ] **Step 3: Commit**

```bash
git add .specify/memory/constitution.md
git commit -m "chore(constitution): require example for new public config/behavior (Examples for new abilities)"
```

---

## Task 3: Final validation

**Files:** N/A (commands only)

- [ ] **Step 1: Run helm template with new example**

From repo root:  
`helm template test ./charts/gateway-api/ -f ./examples/gateway-api/infrastructure-parameters.yaml`  
Expected: No errors; ConfigMap and Gateway with parametersRef present.

- [ ] **Step 2: Run helm lint**

`helm lint ./charts/gateway-api/`  
Expected: 0 chart(s) failed.

---

## Completion

After all tasks: the gateway-api chart has a documented example for `infrastructure.parameters`, and the constitution requires an example for any future new public configuration or behavior. Plan complete; ready to execute.
