## This helm chart allows to create sentry relay app in kubernetes cluster https://docs.sentry.io/product/relay/

Install: `helm repo add dasmeta https://dasmeta.github.io/helm` then `helm upgrade --install my-relay dasmeta/sentry-relay -f values.yaml`. Public values: [values.yaml](./values.yaml). Examples: [examples/sentry-relay/](../../examples/sentry-relay/). Replace upstream/credentials with your values (no literal secrets in examples).

### Key values

| Key | Description | Default / Example |
| --- | ----------- | ----------------- |
| `mode` | Relay mode: proxy, static, or managed | `proxy` |
| `upstream` | Sentry ingest URL (e.g. https://&lt;ORG-ID&gt;.ingest.sentry.io) | required for proxy/managed |
| `workload` | K8s workload type | `DaemonSet` |
| `loggingLevel` | Log level | `info` |
| `credentials` | Required for managed mode; secretKey, publicKey, id | commented out by default |
| `projects` | Required for static mode; project configs | commented out by default |

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
