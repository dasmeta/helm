# Base Chart PodDisruptionBudget Safety Design

> **Amendment, 2026-09-14.** Two decisions below were superseded during review and are left in place as the
> record of what was originally decided. The chart is the authority; `charts/base/README.md` describes the
> shipped behaviour.
>
> 1. **Rounding.** This document states that Kubernetes rounds `maxUnavailable` percentages *down*. That is
>    true of a Deployment rolling update and false of a PodDisruptionBudget: the disruption controller
>    resolves both fields with `roundUp=true`. The guard built on the wrong rule rejected safe
>    configurations.
> 2. **The default.** `maxUnavailable: 1` became `"25%"`, which Kubernetes resolves against the *current*
>    replica count rather than the floor fixed at template time.

**Ticket:** DMVP-10430 (case group B)

## Context

A PodDisruptionBudget that permits zero voluntary evictions blocks every
drain-based operation: node consolidation, spot-replacement drains, and managed
node group upgrades, which fail on pod eviction. The symptom reaches the
operator as "node scaling is stuck" or "the cluster upgrade is stuck", so the
investigation starts nowhere near the service that caused it.

The `base` chart shipped `pdb.enabled: false`, so most services had no budget at
all and a single drain could take every replica of a service at once. At the
same time, the pattern demonstrated in this repository's own examples paired
`autoscaling.minReplicas: 1` with `pdb.minAvailable: 1` — a budget permitting
nothing. Both failure directions were live simultaneously: services with no
protection, and services whose protection blocked the cluster.

A review tied a series of incidents to a small set of causes, of which this was
one. Anyone copying `examples/base/basic.yaml` inherited the antipattern.

## Goal

Make the chart safe for node drains by default, without it ever being possible
to produce a budget that blocks a drain — including when a service sets one
explicitly.

## Interface

```yaml
pdb:
  enabled: <derived>     # created automatically when the effective replica floor is >= 2
  maxUnavailable: 1      # default; always permits exactly one eviction
  # minAvailable: 1      # supported alternative; mutually exclusive with maxUnavailable
```

The **effective replica floor** is `autoscaling.minReplicas` when autoscaling is
enabled, otherwise `replicaCount`. Every disruption decision is judged against
that number. This mirrors `deployment.yaml`, which omits `replicas` entirely
under autoscaling, making the autoscaler minimum the only lower bound.

## Behaviour

1. Floor `>= 2` and nothing configured: render `maxUnavailable: 1`.
2. Floor `< 2`: render no budget. A budget over one replica either blocks every
   drain or protects nothing.
3. Any budget permitting zero evictions at the floor: **refuse to render**,
   whether it came from the default or from the service.
4. `minAvailable` and `maxUnavailable` together: refuse. The Kubernetes API
   permits only one.
5. A service supplying its own valid budget renders exactly that, unchanged.
6. A service with `pdb.enabled: false` renders no budget and does not fail.

## Key decisions

**The default is `maxUnavailable: 1`, not a value derived from the floor.** It
permits exactly one eviction at any floor of 2 or more, so it can never resolve
to zero, and it needs no arithmetic against the floor — removing a whole class
of rounding bug. It is also the structural opposite of the antipattern being
removed, which is `minAvailable` mirroring the replica floor.

**Refuse rather than silently clamp.** A service owner who asked for a
drain-blocking budget holds an incorrect assumption; correcting it silently
leaves that assumption in place, which is the same invisible failure this work
exists to end. Silently ignoring a value is not refusing it, it is hiding it.

**Validation runs before the enabled check, unconditionally.** Placing it after
would let an invalid configuration pass whenever the budget is disabled or the
floor is below 2 — precisely the case that must fail.

**Rounding follows Kubernetes' own rules**, so a percentage is judged the way
the API server will judge it: `minAvailable` rounds up, `maxUnavailable` rounds
down. `25%` of floor 2 rounds down to 0 permitted evictions and is refused.

**Failure uses Helm's `fail`**, which aborts with a non-zero exit code and a
matchable message. No unit-test plugin is introduced, per operator direction.
The message names the offending value, the floor it was judged against, and the
accepted range — asserted by the tests, so it is a contract, not cosmetics.

## Audit of existing configurations

Of 18 example files configuring a budget, **15 would be refused**: all carry
`autoscaling.minReplicas: 1` with `pdb.minAvailable: 1`, and every one renders a
drain-blocking budget today.

All 18 have their now-redundant `pdb:` blocks removed so the safe default
demonstrates itself and the examples stop teaching the antipattern. The three
currently-valid ones move to the more conservative default.

Two `maxUnavailable: 0` hits elsewhere in the repository were checked and are
**not** budgets — they are deployment `rollingUpdate` strategies, where
`maxUnavailable: 0` is a legitimate surge-only rollout. Out of scope, untouched.

## Compatibility

Breaking, and released as `base` 0.4.0. Budgets now render by default at a floor
of 2 or more, and configurations permitting zero evictions are refused at render
time rather than deploying a budget that wedges the cluster. Migration notes are
in `charts/base/README.md`.

The upstream EKS module's assessment script reports affected services before the
upgrade: `scripts/eks-assess.sh` section E3 lists renders that will fail, and
section E1 lists zero-eviction budgets already live in a cluster.

## Out of scope

Zone-level topology spread (case B4), load balancer readiness gates (case B7),
retuning the pre-stop sleep (case B6, needs a live cluster under load), and
correcting individual services found by the audit. Producing the list is in
scope; applying corrections beyond this repository's examples is not.
