{{/*
Expand the name of the chart.
*/}}
{{- define "gateway-api.name" -}}
{{- default .Chart.Name .Values.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gateway-api.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "" .Values.nameOverride }}
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
{{- define "gateway-api.chart" -}}
{{- printf "%s-%s" (include "gateway-api.name" .) .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gateway-api.labels" -}}
helm.sh/chart: {{ include "gateway-api.chart" . }}
{{ include "gateway-api.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- $parentChartName := "" }}
{{- if .Values.parentChart }}
{{- if .Values.parentChart.name }}
{{- $parentChartName = .Values.parentChart.name }}
{{- end }}
{{- end }}
{{- if $parentChartName }}
helm.sh/parent-chart: {{ $parentChartName | quote }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gateway-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gateway-api.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Name of the ConfigMap generated from gateway infrastructure.parameters.
Used when infrastructure.parameters is set and non-empty.
*/}}
{{- define "gateway-api.infrastructureConfigMapName" -}}
{{- $outer := index . 0 -}}
{{- $gateway := index . 1 -}}
{{- include "gateway-api.fullname" $outer }}-infra-{{ $gateway.name }}
{{- end }}
