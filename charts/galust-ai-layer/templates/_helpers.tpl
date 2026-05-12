{{/*
Expand the name of the chart.
*/}}
{{- define "galust-ai-layer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "galust-ai-layer.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := include "galust-ai-layer.name" . }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "galust-ai-layer.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ include "galust-ai-layer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Image pull secret name used by the optional generated dockerconfigjson Secret.
*/}}
{{- define "galust-ai-layer.imagePullSecretName" -}}
{{- default "ecr-secret" .Values.imagePullSecret.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Name used for the optional ECR credentials refresh resources.
*/}}
{{- define "galust-ai-layer.ecrCredentialsRefreshName" -}}
{{- printf "%s-ecr-refresh" (include "galust-ai-layer.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Service account name used by the optional ECR credentials refresh job.
*/}}
{{- define "galust-ai-layer.ecrCredentialsRefreshServiceAccountName" -}}
{{- default (include "galust-ai-layer.ecrCredentialsRefreshName" .) .Values.ecrCredentialsRefresh.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- end }}
