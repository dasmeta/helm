# Render Contract: Service-Level Deny All

## Service-level deny-all enabled

Command:

```bash
helm template ztm-service-deny-all ./charts/zero-trust-mesh -n default -f ./charts/zero-trust-mesh/tests/service-deny-all-values.yaml
```

Expected output:

- Includes a `networking.k8s.io/v1` `NetworkPolicy`.
- NetworkPolicy selects only the configured workload labels.
- NetworkPolicy has `policyTypes` containing both `Ingress` and `Egress`.
- NetworkPolicy has no ingress or egress allow rule entries.
- Includes a `security.istio.io/v1` `AuthorizationPolicy`.
- AuthorizationPolicy selects only the configured workload labels.
- Does not include namespace baseline deny-all resource names unless namespace baseline is separately enabled.

## Disabled default

Command:

```bash
helm template ztm-default ./charts/zero-trust-mesh -n default
```

Expected output:

- Does not render service-level deny-all resources.
- Does not render sample allow rules.

## NetworkPolicy disabled

When `serviceDenyAll.enabled: true` and `networkPolicy.enabled: false`:

- Does not render the service-level NetworkPolicy.
- May still render the service-level AuthorizationPolicy if Istio is enabled.

## Istio disabled

When `serviceDenyAll.enabled: true` and `istio.enabled: false`:

- Does not render the service-level AuthorizationPolicy.
- May still render the service-level NetworkPolicy if NetworkPolicy is enabled.

## Existing allow rules

Existing service, host, and IP examples must continue rendering without behavior changes.
