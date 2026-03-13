# Helm Chart Test

A simple Helm chart for Kubernetes (nginx-based) used for testing.

## Install

```bash
helm repo add dasmeta https://dasmeta.github.io/helm
helm upgrade --install my-test dasmeta/helm-chart-test -f values.yaml
```

Public values: [values.yaml](./values.yaml). Examples: [examples/helm-chart-test/](../../examples/helm-chart-test/). From repo root: `helm template test charts/helm-chart-test -f examples/helm-chart-test/minimal.yaml`.

### Key values

| Key | Description | Default / Example |
| --- | ----------- | ----------------- |
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Container image repository | `nginx` |
| `image.tag` | Image tag | `stable` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `ingress.enabled` | Enable ingress | `false` |
