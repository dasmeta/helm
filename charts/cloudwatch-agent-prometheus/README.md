# CloudWatch Agent Prometheus

Helm chart to deploy the CloudWatch agent for Prometheus metrics in Kubernetes.

## Install

```bash
helm repo add dasmeta https://dasmeta.github.io/helm
helm upgrade --install my-cw-agent dasmeta/cloudwatch-agent-prometheus -f values.yaml
```

Public values: [values.yaml](./values.yaml). Examples: [examples/cloudwatch-agent-prometheus/](../../examples/cloudwatch-agent-prometheus/). From repo root: `helm template test charts/cloudwatch-agent-prometheus -f examples/cloudwatch-agent-prometheus/minimal.yaml`. Replace `clusterName` and `region` with your cluster/region (no literal secrets in examples).

### Key values

| Key | Description | Default / Example |
| --- | ----------- | ----------------- |
| `clusterName` | EKS/cluster name for CloudWatch | required; replace with your value |
| `region` | AWS region | e.g. `us-east-1` |
| `image.repository` | CloudWatch agent image | `amazon/cloudwatch-agent` |
| `image.tag` | Image tag | see values.yaml |
| `resources` | CPU/memory limits and requests | example in values.yaml |
| `serviceAccount.create` | Create service account | `true` |
