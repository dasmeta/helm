# Research: Gateway Direct Response Configuration

## Decision 1: Use Istio EnvoyFilter for non-403 direct responses

- **Decision**: Implement non-403 direct responses through EnvoyFilter-backed configuration.
- **Rationale**: EnvoyFilter natively supports direct response status/body behavior and aligns with the validated example provided for gateway context.
- **Alternatives considered**:
  - Reusing AuthorizationPolicy for all statuses (rejected: existing behavior is intentionally only preserved for 403 flow).
  - Service-level response handling (rejected: does not meet gateway-level requirement and introduces app coupling).

## Decision 2: Preserve AuthorizationPolicy 403 path as authoritative

- **Decision**: Existing AuthorizationPolicy-driven 403 behavior remains unchanged and takes precedence when overlap could occur.
- **Rationale**: Backward compatibility and risk reduction are explicit feature constraints and were clarified by user input.
- **Alternatives considered**:
  - Allow direct-response override of 403 (rejected: regression risk and conflicts with explicit requirement).
  - Fail on any overlap configuration (rejected: too restrictive and reduces operability).

## Decision 3: Constrain status code range and default body behavior

- **Decision**: Direct-response status must be in range 200-599; body defaults to empty string when omitted.
- **Rationale**: Clarified requirement ensures predictable behavior and testable validation boundaries.
- **Alternatives considered**:
  - Allow 100-599 (rejected: informational status responses are not meaningful for direct-response use case).
  - Restrict to 4xx/5xx only (rejected: unnecessary limitation for valid gateway response use cases).

## Decision 4: Keep feature opt-in through values contract

- **Decision**: Feature is disabled/unconfigured by default; operators explicitly configure rules via chart values.
- **Rationale**: Preserves default install stability and satisfies constitution simplicity/defaults principle.
- **Alternatives considered**:
  - Enable by default with empty rule scaffold (rejected: increases complexity and surprise in current deployments).

## Decision 5: Validation strategy for implementation completion

- **Decision**: Validate with `helm lint` and `helm template` for default values, new/updated direct-response example, and existing gateway-api examples for regression.
- **Rationale**: Required by constitution and sufficient to verify rendering correctness and backward compatibility at chart level.
- **Alternatives considered**:
  - Only render new example (rejected: insufficient regression coverage).
  - Rely solely on CI (rejected: violates local validation expectation before completion).
