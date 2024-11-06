# This helm chart allows to create flagger custom metric templates to use in canary rollout

## There is option named `createNginxCustomMetricTemplates`(which is true by default) to create nginx custom metrics named `request-success-rate-custom` and `request-duration-custom` 

## example of custom metric templates
```yaml
metricTemplates:
  - name: my-custom-request-rate-metric-template
    query: |
      sum(rate(nginx_ingress_controller_requests{exported_namespace="{{ namespace }}",ingress="{{ ingress }}",status!~"5.*"}[1m]))/sum(rate(nginx_ingress_controller_requests{exported_namespace="{{ namespace }}",ingress="{{ ingress }}"}[1m]))*100

```