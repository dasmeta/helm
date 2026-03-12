# 📦 Kubernetes Event Enricher Chart

This Helm chart deploys a lightweight Node.js service that enriches Kubernetes `Event` objects with full resource definitions (e.g., Pod, Deployment, HPA) and forwards them to a downstream webhook

---

## 🚀 Features

- Receives Kubernetes events via webhook (e.g., from [`kubernetes-event-exporter`](https://github.com/bitnami/charts/tree/main/bitnami/kubernetes-event-exporter))
- Enriches events with full resource manifest (Pod, Deployment, CronJob, etc.)
- Forwards enriched data to a downstream HTTP endpoint
- Supports graceful shutdowns and readiness/liveness probes
- Scales automatically with HPA

---

Public values: [values.yaml](./values.yaml). Examples: [examples/kubernetes-event-exporter-enriched/](../../examples/kubernetes-event-exporter-enriched/). From repo root: `helm template test charts/kubernetes-event-exporter-enriched -f examples/kubernetes-event-exporter-enriched/minimal.yaml`.

### Key values

| Key | Description | Default / Example |
| --- | ----------- | ----------------- |
| `webhookEndpoint` | Downstream webhook URL for enriched events | required; set your endpoint |
| `kubernetes-event-exporter.config` | Event exporter config (receivers, route) | enricher webhook to local enricher service |
| `kubernetes-event-exporter.image.repository` | Event exporter image | `bitnamilegacy/kubernetes-event-exporter` |

## 🛠 Installation

```bash
helm repo add dasmeta https://dasmeta.github.io/helm
helm install kubernetes-events-exporter-enriched dasmeta/kubernetes-event-exporter-enriched \
  --version 0.1.2 \
  --namespace kubernetes-event-exporter \
  --set webhookEndpoint="https://n8n.example.com/webhook/k8s-events"
```
