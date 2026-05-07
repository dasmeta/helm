# Research: Zero Trust Target Pod Labels

## Decisions

### Use a label map override named `targetPodLabels`

**Decision**: Add `allowTo[].targetPodLabels` as a map and render it into both policy target selectors.

**Rationale**: The problem is selector mismatch, not service discovery. A label map maps directly onto Kubernetes `matchLabels` and Istio workload selectors, keeps values simple, and avoids inventing a second selector language.

**Alternatives considered**:

- `targetSelector`: More generic but less clear that only pod/workload labels are supported.
- `targetServiceLabels`: Incorrect scope; AuthorizationPolicy and NetworkPolicy select workloads/pods, not Services.
- `matchExpressions`: More flexible, but not needed for the reported mismatch and would expand the values contract significantly.

### Keep `app.kubernetes.io/name: <service>` as fallback

**Decision**: If `targetPodLabels` is omitted, empty, or null, keep the existing selector.

**Rationale**: Existing consumers already rely on this behavior. The new value is an opt-in override for workloads that do not use the recommended label.

### Share selector rendering through a helper

**Decision**: Add a `ztm.targetPodLabels` helper and call it from both target policy templates.

**Rationale**: A shared helper prevents NetworkPolicy and AuthorizationPolicy selectors from diverging and keeps fallback behavior in one place.

## Official Documentation Notes

- Kubernetes NetworkPolicy uses `spec.podSelector` to select the pods the policy applies to; official examples use `podSelector.matchLabels` for label-based pod selection.
- Kubernetes label selector docs define `matchLabels` as a map of key/value pairs whose requirements are ANDed.
- Istio AuthorizationPolicy uses `spec.selector` to choose workloads for a policy.
- Istio WorkloadSelector defines `matchLabels` as a `map<string, string>` for selecting pods/VMs; multiple labels must all match.

Sources checked:

- Kubernetes Network Policies: https://kubernetes.io/docs/concepts/services-networking/network-policies/
- Kubernetes Labels and Selectors: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
- Istio AuthorizationPolicy reference: https://istio.io/latest/docs/reference/config/security/authorization-policy/
- Istio WorkloadSelector reference: https://istio.io/latest/docs/reference/config/type/workload-selector/

## Validation Notes

The render assertion should verify:

- custom labels appear in both generated policy target selectors
- the old default target selector does not appear for the customized target service
- default chart rendering still keeps the old selector when no override is provided
