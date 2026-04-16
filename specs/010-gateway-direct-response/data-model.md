# Data Model: Gateway Direct Response Configuration

## Entity: DirectResponseRule

- **Description**: A configurable rule that returns a static response directly from the gateway when request match conditions are met.
- **Fields**:
  - `enabled` (boolean): whether the rule is active.
  - `match` (object): request matching criteria (e.g., host/path-related match conditions).
  - `statusCode` (integer): HTTP status returned by gateway.
  - `body` (string, optional): response payload; defaults to empty string when omitted.
- **Validation Rules**:
  - `statusCode` must be within 200-599.
  - `body` defaults to `""` when absent.
  - `match` must be present for an active rule.

## Entity: Authorization403Behavior

- **Description**: Existing 403 response behavior configured through AuthorizationPolicy.
- **Fields**:
  - `policyConfigured` (boolean): indicates whether current 403 policy path is configured.
  - `precedence` (enum): fixed as `higher-than-direct-response` when overlap exists.
- **Validation Rules**:
  - This behavior is unchanged by this feature.
  - If overlap occurs, this behavior is authoritative.

## Entity: GatewayMatchCondition

- **Description**: Rule criteria used to determine whether a direct response is applied for a request.
- **Fields**:
  - `host` (string, optional)
  - `pathPrefix` (string, optional)
  - `additionalConditions` (object, optional)
- **Validation Rules**:
  - At least one supported condition must be present for a meaningful match.
  - Condition format must align with supported gateway matching semantics.

## Relationships

- A `DirectResponseRule` references one `GatewayMatchCondition`.
- `Authorization403Behavior` and `DirectResponseRule` may target overlapping traffic; precedence rule enforces `Authorization403Behavior` first for 403 flow.

## State Transitions

- **Rule Lifecycle**:
  - `NotConfigured` -> `ConfiguredDisabled` (values present but disabled)
  - `ConfiguredDisabled` -> `ConfiguredEnabled` (enabled)
  - `ConfiguredEnabled` -> `ConfiguredDisabled` (disabled)
  - `ConfiguredEnabled` -> `Invalid` (validation failure, e.g., out-of-range status)
