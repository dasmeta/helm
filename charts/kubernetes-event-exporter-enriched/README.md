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

## 🛠 Installation

```bash
helm repo add dasmeta https://dasmeta.github.io/helm
helm install kubernetes-events-exporter-enriched dasmeta/kubernetes-events-exporter-enriched \
  --version 0.1.0 \
  --namespace kubernetes-event-exporter \
  --set webhookEndpoint=https://n8n.example.com/webhook/k8s-events
```
