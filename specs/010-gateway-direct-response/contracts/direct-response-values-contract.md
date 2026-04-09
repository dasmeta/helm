# Contract: Gateway Direct Response Values

## Purpose

Define the consumer-facing configuration contract for direct-response behavior in the `gateway-api` chart.

## Contract Rules

1. Direct-response configuration is optional and opt-in.
2. Direct-response status code must be an integer in range 200-599.
3. Direct-response body is optional; when omitted, effective value is empty string.
4. Existing AuthorizationPolicy-based 403 behavior remains unchanged and takes precedence if overlap exists.
5. Match conditions must be provided for active rules.

## Consumer Expectations

- Invalid status values fail chart validation/rendering.
- Omitting direct-response configuration preserves current behavior.
- Omitting body never results in implicit non-empty payload.
- Existing 403 behavior is not overridden by this feature.

## Acceptance Alignment

- Supports FR-001 through FR-010 in `spec.md`.
- Supports SC-001 through SC-004 by enabling deterministic, testable configuration outcomes.
