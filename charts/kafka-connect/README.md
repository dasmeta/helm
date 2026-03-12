# Kafka Connect Helm Chart

This Helm chart deploys Kafka Connect on Kubernetes, currently configured to work with Google Cloud Storage (GCS) for sink functionality. It includes setups like a Kafka Connect deployment integrated with a GCS Sink Connector and a Schema Registry, providing flexible environment configurations.

## Prerequisites

- Kubernetes 1.18+
- Helm 3.0+
- Configured `kubectl` connected to your Kubernetes cluster
- Google Cloud credentials configured if GCS functionality is utilized (`gcs-credentials` secret has to exist in the namespace where the chart will be deployed and should include the json of GCP Service Account credentials).
For example:
```
apiVersion: v1
data:
  gcs-credentials.json: "your-gcs-sa-credentials"
kind: Secret
metadata:
  name: gcs-credentials
  namespace: kafka
type: Opaque
```

Public values: [values.yaml](./values.yaml). Examples: [examples/kafka-connect/](../../examples/kafka-connect/). From repo root: `helm template test charts/kafka-connect -f examples/kafka-connect/minimal.yaml`.

### Key values

| Key | Description | Default / Example |
| --- | ----------- | ----------------- |
| `base` | Base chart subchart values (replicaCount, image, service, etc.) | example in values.yaml |
| `base.schemaRegistry.enabled` | Enable Schema Registry | set per env |
| `base.schemaRegistry.url` | Schema Registry URL | e.g. http://schema-registry:8081 |
| Connector configs | GCS Sink and other connectors | example in values.yaml; requires gcs-credentials secret |

## Installation

### Add Helm Repository

If the chart is hosted in a Helm repository:

```bash
helm repo add dasmeta https://dasmeta.github.io/helm/
helm install kafka-connect dasmeta/kafka-connect -f values.yaml --version 1.0.0
