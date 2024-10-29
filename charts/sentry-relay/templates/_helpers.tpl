{{/*
Expand the name of the chart.
*/}}
{{- define "sentry-relay.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sentry-relay.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sentry-relay.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sentry-relay.labels" -}}
helm.sh/chart: {{ include "sentry-relay.chart" . }}
{{ include "sentry-relay.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sentry-relay.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sentry-relay.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sentry-relay.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sentry-relay.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
the content of sentry relay /work/.relay/config.yaml config file
*/}}
{{- define "sentry-relay.config.yaml" -}}
  relay:
    mode: {{ .Values.mode }}
    upstream: {{ .Values.upstream }}
    host: 0.0.0.0
    port: {{ .Values.service.port }}

    logging:
      level: {{ .Values.loggingLevel }}
      format: json
{{- end }}

{{/*
the content of sentry relay /work/.relay/credentials.json managed mode credentials file
*/}}
{{- define "sentry-relay.managed.credentials.json" -}}
secret_key: {{ .Values.credentials.secretKey }}
public_key: {{ .Values.credentials.publicKey }}
id: {{ .Values.credentials.id }}
{{- end }}
