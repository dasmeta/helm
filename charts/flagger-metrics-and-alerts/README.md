# This helm chart allows to create flagger custom metric templates and alert providers to use in canary rollout, docs can found here https://docs.flagger.app/usage/metrics https://docs.flagger.app/usage/alerting

Install: `helm repo add dasmeta https://dasmeta.github.io/helm` then `helm upgrade --install my-flagger dasmeta/flagger-metrics-and-alerts -f values.yaml`. Public values: [values.yaml](./values.yaml). Examples: [examples/flagger-metrics-and-alerts/](../../examples/flagger-metrics-and-alerts/). From repo root: `helm template test charts/flagger-metrics-and-alerts -f examples/flagger-metrics-and-alerts/minimal.yaml`.

### Key values

| Key | Description | Default / Example |
| --- | ----------- | ----------------- |
| `metricTemplatesDefaultProvider` | Default Prometheus for metric templates | `type: prometheus`, `address: http://prometheus-service.monitoring:9090` |
| `createNginxCustomMetricTemplates` | Create nginx custom metric templates (exported_namespace) | `false` |
| `metricTemplates` | Map of custom metric template name → query config | `{}`; example in values.yaml |
| `alertProviders` | Map of Flagger alert provider name → spec | `{}`; example in values.yaml |

## There is option named `createNginxCustomMetricTemplates`(false by default) which allows to create nginx custom metrics named `request-success-rate-nginx-custom` and `request-duration-nginx-custom`, this ones are handy to use for nginx flagger provider canaries in case when the default `request-success-rate` and `request-duration` one not work because of the filter `namespace` should be renamed to `exported_namespace` in query

## example of flagger custom metric template creation helm values.yaml
```yaml
metricTemplates:
  my-custom-request-rate-metric-template:
    # provider: # (optional, defaults to metricTemplatesDefaultProvider)
    #   type: prometheus
    #   address: http://prometheus-service.monitoring:9090
    query: |
      sum(rate(nginx_ingress_controller_requests{exported_namespace="{{ namespace }}",ingress="{{ ingress }}",status!~"5.*"}[1m]))/sum(rate(nginx_ingress_controller_requests{exported_namespace="{{ namespace }}",ingress="{{ ingress }}"}[1m]))*100
```

## example of flagger alert provider creation helm values.yaml
```yaml
alertProviders:
  on-call: # The uniq name of channel
    type: slack
    channel: on-call-alerts # The channel of notify/alerting (optional default to "general") # The channel of notify/alerting (optional default to "general")
    username: flagger # The sender name in notify/alert (optional default to "flagger")
    # webhook address (ignored if secretRef is specified)
    # or https://slack.com/api/chat.postMessage if you use token in the secret
    address: https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
    # proxy: http://my-http-proxy.com # optional http/s proxy
    # secretRef: # secret containing the webhook address (optional)
    #   name: on-call-url
```
