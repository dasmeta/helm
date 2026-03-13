# Gateway API — Infrastructure Parameters (ConfigMap from values) Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `gateways[].infrastructure.parameters` so the chart can generate a ConfigMap from service/deployment/serviceAccount/horizontalPodAutoscaler/podDisruptionBudget configs and attach it via `infrastructure.parametersRef`, while preserving manual `parametersRef`.

**Architecture:** One new template emits a ConfigMap per gateway that has non-empty `infrastructure.parameters`; the existing Gateway template is updated to set `parametersRef` to that ConfigMap when `parameters` is used, otherwise keep user-supplied `parametersRef`. Parameter values: string → as-is, non-string → toYaml; empty string → omit key. ConfigMap name: `{fullname}-infra-{gateway.name}`; namespace = Gateway namespace.

**Tech Stack:** Helm 3, Kubernetes Gateway API (gateway.networking.k8s.io/v1), YAML/templates.

**Spec:** [spec.md](./spec.md) | **Branch:** `005-gateway-api-infrastructure-parameters`

---

## Summary

Implement FR-001–FR-010 from the spec: new optional `infrastructure.parameters` object with keys `service`, `deployment`, `serviceAccount`, `horizontalPodAutoscaler`, `podDisruptionBudget`. When present and non-empty, the chart emits a ConfigMap (name = chart fullname + `-infra-` + gateway name, namespace = Gateway namespace) and sets the Gateway’s `spec.infrastructure.parametersRef` to it. When `parameters` is not set, existing `parametersRef` is unchanged. When both are set, `parameters` wins. Empty string values are omitted from ConfigMap data; string values used as-is, other types serialized with `toYaml`.

## Technical Context

**Language/Version:** Helm 3 (Go templates), YAML  
**Primary Dependencies:** gateway-api chart only  
**Testing:** `helm template`, `helm lint` with default values and with values that use `infrastructure.parameters` and `parametersRef`  
**Constraints:** Only the five parameter keys; no validation of parameter YAML content; standard Helm replace on upgrade  
**Scale:** One ConfigMap per gateway that has non-empty parameters; gateways list can be one or many

## Constitution Check

| Principle | Gate | Status |
|-----------|------|--------|
| I. Chart-First | Change only gateway-api chart under `charts/gateway-api/` | PASS |
| II. Values Contract | New config only via `values.yaml`; no hardcoded env-specific values | PASS |
| III. Lint & Template | Chart MUST pass `helm lint` and `helm template` with default and with parameters examples | PASS |
| IV. Versioning & Compatibility | Bump chart version in `Chart.yaml` (PATCH) when templates/values change | PASS |
| V. Simplicity & Defaults | Default gateways: []; parameters optional; existing parametersRef unchanged | PASS |
| README / values sync | README values table and values.yaml MUST be updated together for new keys | PASS |

## File Structure

**Modified:**

- `charts/gateway-api/templates/_helpers.tpl` — Add helper for ConfigMap name (optional; can inline in templates).
- `charts/gateway-api/templates/gateway.yaml` — When `infrastructure.parameters` is non-empty, set `parametersRef` to generated ConfigMap; else keep existing `parametersRef`.
- `charts/gateway-api/values.yaml` — Document and example `infrastructure.parameters`; keep existing `parametersRef` example.
- `charts/gateway-api/README.md` — Document `infrastructure.parameters` and add/update values table per constitution.
- `charts/gateway-api/Chart.yaml` — Bump `version` (PATCH).

**Created:**

- `charts/gateway-api/templates/gateway-infrastructure-configmap.yaml` — Emit one ConfigMap per gateway that has at least one non-empty entry in `infrastructure.parameters`; data keys = parameter keys; values = string as-is or toYaml for non-string; omit empty string.

**Not created:** No new chart or subchart; no schema validation.

---

## Task 1: Helper for infrastructure ConfigMap name

**Files:** Modify: `charts/gateway-api/templates/_helpers.tpl`

- [ ] **Step 1: Add named template for infrastructure ConfigMap name**

Append to `_helpers.tpl` a helper that takes root context and gateway and returns the ConfigMap name so templates stay DRY:

```yaml
{{/*
Name of the ConfigMap generated from gateway infrastructure.parameters.
Used when infrastructure.parameters is set and non-empty.
*/}}
{{- define "gateway-api.infrastructureConfigMapName" -}}
{{- $outer := index . 0 -}}
{{- $gateway := index . 1 -}}
{{- include "gateway-api.fullname" $outer }}-infra-{{ $gateway.name }}
{{- end -}}
```

- [ ] **Step 2: Verify template parses**

Run: `helm template test charts/gateway-api --debug 2>&1 | head -5`  
Expected: No template error; may show "Error: ..." only if chart has other requirements (e.g. missing values). Focus on no "parse error" for _helpers.tpl.

- [ ] **Step 3: Commit**

```bash
git add charts/gateway-api/templates/_helpers.tpl
git commit -m "feat(gateway-api): add helper for infrastructure ConfigMap name"
```

---

## Task 2: ConfigMap template for infrastructure.parameters

**Files:** Create: `charts/gateway-api/templates/gateway-infrastructure-configmap.yaml`

- [ ] **Step 1: Add template that emits ConfigMap per gateway with non-empty parameters**

Create the file. Logic:

1. Range over gateways (same as gateway.yaml: `ternary $gateways (list $gateways) (kindIs "slice" $gateways)`).
2. For each gateway, set `$params := $gateway.infrastructure.parameters` (if absent, skip).
3. Determine "has non-empty params": for each key in `service`, `deployment`, `serviceAccount`, `horizontalPodAutoscaler`, `podDisruptionBudget`, if key is present and value is not the empty string, then "has non-empty" is true. In Helm: use `if and (hasKey $params "service") (ne (index $params "service") "")` etc., or a single condition that checks if any of the five keys is present and non-empty (e.g. build a list of keys that have non-empty values and check length).
4. If has non-empty params: emit one ConfigMap with name `{{ include "gateway-api.infrastructureConfigMapName" (list $outer $gateway) }}`, namespace = same as Gateway: `{{ default "istio-system" (default $gateway.namespace $outer.Release.Namespace) }}`, labels from `gateway-api.labels`, and `data:` with only the keys that are present and not empty string. For each such key: if value is string use as-is (multiline with `|` or indent); if not string use `toYaml`.

Example structure (adapt to exact Helm syntax):

```yaml
{{- if .Values.gateways }}
{{- $outer := . }}
{{- $gateways := .Values.gateways }}
{{- $gatewayList := ternary $gateways (list $gateways) (kindIs "slice" $gateways) }}
{{- range $gateway := $gatewayList }}
{{- $params := dig "infrastructure" "parameters" dict $gateway }}
{{- $hasParams := false }}
{{- range $k := list "service" "deployment" "serviceAccount" "horizontalPodAutoscaler" "podDisruptionBudget" }}
{{- if and (hasKey $params $k) (not (eq (toString (index $params $k)) "")) }}
{{- $hasParams = true }}
{{- end }}
{{- end }}
{{- if $hasParams }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "gateway-api.infrastructureConfigMapName" (list $outer $gateway) }}
  namespace: {{ default "istio-system" (default $gateway.namespace $outer.Release.Namespace) | quote }}
  labels:
    {{- include "gateway-api.labels" $outer | nindent 4 }}
data:
  {{- range $k := list "service" "deployment" "serviceAccount" "horizontalPodAutoscaler" "podDisruptionBudget" }}
  {{- $v := index $params $k }}
  {{- if and (hasKey $params $k) (not (eq (toString $v) "")) }}
  {{ $k }}: |
    {{- if kindIs "string" $v }}
    {{- $v | nindent 4 }}
    {{- else }}
    {{- $v | toYaml | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
```

Note: Ensure trailing newlines and indentation so emitted YAML is valid. For `data` values that are blocks, use `|` and nindent the content; for toYaml the result is already a string so indent consistently (e.g. 4 spaces).

- [ ] **Step 2: Run helm template with parameters values**

Create a temporary values file (e.g. ` /tmp/gw-params.yaml`) with one gateway that has `infrastructure.parameters` with at least `service` as object and `deployment` as string. Example:

```yaml
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

Run: `helm template test charts/gateway-api -f /tmp/gw-params.yaml`  
Expected: One ConfigMap with `data.service` (YAML for LoadBalancer) and `data.deployment` (string "replicas: 2"); one Gateway resource.

- [ ] **Step 3: Commit**

```bash
git add charts/gateway-api/templates/gateway-infrastructure-configmap.yaml
git commit -m "feat(gateway-api): add ConfigMap template for infrastructure.parameters"
```

---

## Task 3: Gateway template — set parametersRef when parameters present

**Files:** Modify: `charts/gateway-api/templates/gateway.yaml`

- [ ] **Step 1: Compute whether this gateway uses generated parameters**

Inside the existing `{{- range $idx, $gateway := ... }}` block, after the opening of the Gateway resource, define a variable (e.g. `$useParams`) that is true when `$gateway.infrastructure.parameters` exists and has at least one non-empty value. Reuse the same logic as in gateway-infrastructure-configmap.yaml (iterate the five keys; if any key present and not empty string, true).

- [ ] **Step 2: When rendering infrastructure, prefer parametersRef from generated ConfigMap**

Current snippet (lines 67–89):

```yaml
  {{- with $gateway.infrastructure }}
  infrastructure:
    {{- with .annotations }}
    ...
    {{- end }}
    {{- with .parametersRef }}
    parametersRef:
    ...
    {{- end }}
  {{- end }}
```

Change to: when `$gateway.infrastructure` exists, always render `infrastructure:`. For `parametersRef`: if `$useParams` is true, emit parametersRef pointing to the generated ConfigMap (group: `""`, kind: `ConfigMap`, name: `{{ include "gateway-api.infrastructureConfigMapName" (list $outer $gateway) }}`, namespace: gateway namespace). Else, use existing `with .parametersRef` block to emit user-supplied parametersRef. Ensure when neither parameters nor parametersRef is set, no parametersRef block is emitted.

- [ ] **Step 3: Verify backward compatibility**

Run: `helm template test charts/gateway-api` with default values (gateways: []). Expected: No Gateway, no ConfigMap.  
Run with a gateway that has only `parametersRef` (no `parameters`):  
e.g. gateways with `infrastructure.parametersRef: { group: "", kind: ConfigMap, name: my-cm, namespace: istio-system }`.  
Expected: No ConfigMap generated; Gateway has the given parametersRef.

- [ ] **Step 4: Verify parameters take precedence**

Run with a gateway that has both `parametersRef` and `parameters` with at least one key. Expected: One ConfigMap generated; Gateway’s parametersRef points to that ConfigMap (not the user-supplied one).

- [ ] **Step 5: Commit**

```bash
git add charts/gateway-api/templates/gateway.yaml
git commit -m "feat(gateway-api): set infrastructure.parametersRef from generated ConfigMap when parameters set"
```

---

## Task 4: values.yaml — document infrastructure.parameters

**Files:** Modify: `charts/gateway-api/values.yaml`

- [ ] **Step 1: Add commented example for infrastructure.parameters**

Near the existing `infrastructure.parametersRef` example (around lines 74–81), add a commented block showing `infrastructure.parameters` with object and string examples, e.g.:

```yaml
#     # Optional: inline parameters; chart creates a ConfigMap and sets parametersRef automatically.
#     parameters:
#       service:
#         type: LoadBalancer
#       deployment: "replicas: 2"
#       # serviceAccount, horizontalPodAutoscaler, podDisruptionBudget: same pattern (object or string)
```

Clarify in comments: each value can be object (serialized to YAML) or string (used as-is); empty string omits the key; when `parameters` is set and non-empty, it overrides any manual `parametersRef`.

- [ ] **Step 2: Keep existing parametersRef example**

Leave the existing `parametersRef` example so both options are documented.

- [ ] **Step 3: Commit**

```bash
git add charts/gateway-api/values.yaml
git commit -m "docs(gateway-api): document infrastructure.parameters in values.yaml"
```

---

## Task 5: README — document parameters and update values table

**Files:** Modify: `charts/gateway-api/README.md`

- [ ] **Step 1: Add infrastructure.parameters to values table**

If the README has a Key / Description / Default or Example table (per constitution), add a row for `gateways[].infrastructure.parameters` (and optionally a row for `gateways[].infrastructure.parametersRef` if not already there). Description: optional object with keys service, deployment, serviceAccount, horizontalPodAutoscaler, podDisruptionBudget; chart creates a ConfigMap and sets parametersRef when non-empty.

- [ ] **Step 2: Add short prose for infrastructure.parameters**

In the section that describes gateways or infrastructure, add 2–3 sentences: you can either set `infrastructure.parametersRef` to an existing ConfigMap, or set `infrastructure.parameters` with the five keys (object or string per key); when `parameters` is set and non-empty, the chart creates a ConfigMap and sets `parametersRef` automatically; empty string values are omitted.

- [ ] **Step 3: Commit**

```bash
git add charts/gateway-api/README.md
git commit -m "docs(gateway-api): README for infrastructure.parameters and values table"
```

---

## Task 6: Validation — helm lint and helm template

**Files:** Test: `charts/gateway-api/`

- [ ] **Step 1: Lint with default values**

Run: `helm lint charts/gateway-api`  
Expected: PASS (0 chart(s) linted, 0 chart(s) failed).

- [ ] **Step 2: Template with default values**

Run: `helm template test charts/gateway-api`  
Expected: No error; may output nothing or only non-Gateway resources if gateways: [].

- [ ] **Step 3: Template with infrastructure.parameters**

Use a values file with one gateway with `infrastructure.parameters` (e.g. service + deployment). Run: `helm template test charts/gateway-api -f <file>.yaml`  
Expected: One ConfigMap (name = fullname-infra-<gateway.name>), one Gateway with spec.infrastructure.parametersRef pointing to that ConfigMap.

- [ ] **Step 4: Template with two gateways with parameters**

Values: two gateways, both with different names and each with `infrastructure.parameters`.  
Expected: Two ConfigMaps with distinct names; two Gateways each with parametersRef to the corresponding ConfigMap.

- [ ] **Step 5: Commit (if any test values file is added under examples/)**

If an example values file was added under `examples/gateway-api/` for this feature, ensure it has the top-line command comment per constitution and commit it.

---

## Task 7: Bump Chart version

**Files:** Modify: `charts/gateway-api/Chart.yaml`

- [ ] **Step 1: Increment version**

Bump `version` by PATCH (e.g. 0.x.y → 0.x.(y+1)). Do not change `appVersion` unless the chart’s application version actually changed.

- [ ] **Step 2: Commit**

```bash
git add charts/gateway-api/Chart.yaml
git commit -m "chore(gateway-api): bump version for infrastructure.parameters feature"
```

---

## Completion

After all tasks: run full `helm lint charts/gateway-api` and `helm template test charts/gateway-api -f <example-with-parameters>.yaml` once more. Confirm SC-001, SC-002, SC-003 from the spec (configurable via values, backward compatibility, lint/template pass and no duplicate ConfigMap names).

Plan complete and saved to `specs/005-gateway-api-infrastructure-parameters/plan.md`. Ready to execute.
