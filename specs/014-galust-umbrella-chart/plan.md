# Implementation Plan: Galust AI Layer Umbrella Chart

**Branch**: `014-galust-umbrella-chart` | **Date**: 2026-05-11 | **Spec**: `specs/014-galust-umbrella-chart/spec.md`
**Input**: Feature specification from `specs/014-galust-umbrella-chart/spec.md`

## Summary

Add `charts/galust-ai-layer` as an umbrella chart that deploys the Galust AI layer components to Kubernetes or EKS. Use one `dasmeta/base` dependency alias per component, expose component enable flags, and carry the existing `ai-layer` deployment defaults into chart values.

## Technical Context

**Language/Version**: Helm 3 chart YAML and Go templates  
**Primary Dependencies**: Published `dasmeta/base` chart version `0.3.2`, matching the `ai-layer` deployment workflows  
**Storage**: Backend uploads PVC, default `ai-layer-strapi-uploads`  
**Testing**: `helm dependency update`, `helm lint`, `helm template`  
**Target Platform**: Kubernetes / EKS  
**Project Type**: Helm chart repository  
**Constraints**: Do not provision AWS IAM trust, ECR repository policy, or database infrastructure in this chart  
**Scale/Scope**: Four long-running Galust workloads

## Constitution Check

The change is chart-scoped and keeps shared chart logic in `charts/base`. It does not copy base templates into the new chart.

## Project Structure

### Documentation

```text
specs/014-galust-umbrella-chart/
├── spec.md
├── plan.md
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
- Keep ingress defaults disabled to avoid installing Galust production hostnames into clusters by accident.
- Provide default image pull secret name `ecr-secret`, with optional chart-rendered docker config secret.
