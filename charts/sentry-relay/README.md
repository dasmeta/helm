## This helm chart allows to create sentry relay app in kubernetes cluster https://docs.sentry.io/product/relay/

Install: `helm repo add dasmeta https://dasmeta.github.io/helm` then `helm upgrade --install my-relay dasmeta/sentry-relay -f values.yaml`. Public values: [values.yaml](./values.yaml). Examples: [examples/sentry-relay/](../../examples/sentry-relay/). Replace upstream/credentials with your values (no literal secrets in examples).

### Key values

| Key | Description | Default / Example |
| --- | ----------- | ----------------- |
| `mode` | Relay mode: proxy, static, or managed | `proxy` |
| `upstream` | Sentry ingest URL (e.g. https://&lt;ORG-ID&gt;.ingest.sentry.io) | required for proxy/managed |
| `workload` | K8s workload type | `DaemonSet` |
| `priorityClassName` | Existing PriorityClass for Relay pods; applies to both workload types | `""` (cluster default) |
| `loggingLevel` | Log level | `info` |
| `credentials` | Required for managed mode; secretKey, publicKey, id | commented out by default |
| `projects` | Required for static mode; project configs | commented out by default |

### Scheduling priority

Required DaemonSet agents can remain Pending when application requests fill a
new node before the agent binds. Configure `priorityClassName` to prioritize Relay
without changing its resource requests. This option uses the standard Kubernetes
pod field. The documented preemption examples target Helm 3 and Kubernetes 1.24
or later, where non-preempting priority is stable.

Create and manage the class in the cluster's infrastructure configuration before
using it in this chart. For example, after reviewing the cluster priority hierarchy:

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: relay-agents
value: 1000
globalDefault: false
preemptionPolicy: PreemptLowerPriority
description: Required Relay agents; may preempt lower-priority workloads.
```

Then set `priorityClassName: relay-agents`; see
[the priority example](../../examples/sentry-relay/priority.yaml). The value `1000`
is illustrative, not a universal safe value. Keep protected workloads at equal
or higher priority. Scheduler preemption respects PodDisruptionBudgets only on
a best-effort basis and can interrupt applications. Set `preemptionPolicy: Never`
on the class if Relay should be prioritized in the queue without evicting other
pods; this does not recover a node already full of requested resources. A missing
class prevents new pods from being admitted. The chart deliberately does not
create or own the cluster-scoped class.

Validate the selected policy on a full non-production node before rollout. A
DaemonSet template change rolls its pods according to its update strategy, so
monitor Relay Ready/Desired, service endpoints, and application readiness throughout
the rollout. Retain the prior Helm revision and values for rollback. Returning
`priorityClassName` to `""` restores the cluster's default priority for recreated
pods; it does not undo application preemptions that have already occurred. Retain
the class until no workloads reference it. Observe at least one representative
node replacement after deployment.

References: [DaemonSet scheduling](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
and [priority and preemption](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/).

### Here are values.yaml file structures for creation relay with sentry cloud by supported proxy, managed or static modes by using minimum configs.
### NOTE:
 - By default it creates relay on proxy mode with DaemonSet workload
 - In case you created sentry cloud on europe region the upstream value is in form https://<ORGANIZATION-ID>.ingest.de.sentry.io
 - It should be possible to use this chart also for non sentry cloud setups, but this is not tested yet


### "proxy" mode (simplest mode without additional configs)
```yaml
# file values-proxy-mode.yaml
upstream: https://<ORGANIZATION-ID>.ingest.sentry.io
```

### "managed" mode (https://docs.sentry.io/product/relay/getting-started/#creating-credentials)
```yaml
# file values-managed-mode.yaml
mode: managed
upstream: https://<ORGANIZATION-ID>.ingest.sentry.io
credentials:
  secretKey: "<SECRET-KEY>"
  publicKey: "<PUBLIC-KEY>"
  id: "<ID>"
```

### "static" mode (https://docs.sentry.io/product/relay/projects/)
```yaml
# file values-static-mode.yaml
mode: static
upstream: https://<ORGANIZATION-ID>.ingest.sentry.io
projects:
  "<PROJECT-ID>":
    slug: "<PROJECT-SLUG>"
    disabled: false
    publicKeys:
      - publicKey: "<PROJECT-PUBLIC-KEY>"
        isEnabled: true
    config:
      allowedDomains: ["*"]
      features: # this options can vary on different setups, please check
        - organizations:session-replay
        - organizations:session-replay-recording-scrubbing
        - organizations:session-replay-combined-envelope-items
        - organizations:session-replay-video-disabled
        - organizations:device-class-synthesis
        - organizations:custom-metrics
        - organizations:profiling
        - organizations:standalone-span-ingestion
        - projects:relay-otel-endpoint
        - projects:discard-transaction
        - organizations:continuous-profiling
        - projects:span-metrics-extraction
        - projects:span-metrics-extraction-addons
        - organizations:indexed-spans-extraction
        - organizations:performance-queries-mongodb-extraction
```
