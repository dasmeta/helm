# Implementation Plan: Galust AI Layer Umbrella Chart

**Branch**: `014-galust-umbrella-chart` | **Date**: 2026-05-11 | **Spec**: `specs/014-galust-umbrella-chart/spec.md`
**Input**: Feature specification from `specs/014-galust-umbrella-chart/spec.md`

## Summary

Add and maintain `charts/galust-ai-layer` as an umbrella chart that deploys the Galust AI layer components to Kubernetes or EKS. Use one `dasmeta/base` dependency alias per service component, expose component enable flags, and carry Galust deployment defaults into chart values. DMVP-10093 extends the chart with the frontend component.

## Technical Context

**Language/Version**: Helm 3 chart YAML and Go templates  
**Primary Dependencies**: Published `dasmeta/base` chart version `0.3.30`, matching the current shared chart release
**Storage**: Backend uploads PVC, default `ai-layer-strapi-uploads`  
**Testing**: `helm dependency update`, `helm lint`, `helm template`  
**Target Platform**: Kubernetes / EKS  
**Project Type**: Helm chart repository  
**Constraints**: Do not provision AWS IAM trust, ECR repository policy, or database infrastructure in this chart  
**Scale/Scope**: Six Galust components: backend, mcp, mcp-use-case, mcp-products, orchestrator, and frontend

## Constitution Check

The change is chart-scoped and keeps shared chart logic in `charts/base`. It does not copy base templates into the new chart.

## Project Structure

### Documentation

```text
specs/014-galust-umbrella-chart/
├── spec.md
├── plan.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code

```text
charts/galust-ai-layer/
├── Chart.yaml
├── README.md
├── values.yaml
└── templates/
    ├── NOTES.txt
    ├── _helpers.tpl
    └── image-pull-secret.yaml
```

## Implementation Notes

- Use dependency `condition` fields so component toggles are native Helm behavior.
- Set `fullnameOverride` defaults to preserve existing Galust service names.
- Keep ingress defaults aligned with existing component behavior and avoid broadening ingress behavior beyond the requested frontend component.
- Provide default image pull secret name `ecr-secret`, with optional chart-rendered docker config secret.
- Add `frontend` as a `dasmeta/base` alias using image `565580475168.dkr.ecr.eu-central-1.amazonaws.com/ai-layer-frontend-app:latest` and port `80`.
