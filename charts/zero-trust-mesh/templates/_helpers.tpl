{{- define "ztm.name" -}}
{{- regexReplaceAll "[^a-z0-9-]+" (lower (default .Chart.Name .Values.nameOverride)) "-" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ztm.fullname" -}}
{{- regexReplaceAll "[^a-z0-9-]+" (lower (printf "%s-%s" .Release.Name (include "ztm.name" .))) "-" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ztm.sanitizeName" -}}
{{- regexReplaceAll "[^a-z0-9-]+" (lower .) "-" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ztm.ipCidr" -}}
{{- $ip := printf "%v" . -}}
{{- if contains "/" $ip -}}
{{- $ip -}}
{{- else if contains ":" $ip -}}
{{- printf "%s/128" $ip -}}
{{- else -}}
{{- printf "%s/32" $ip -}}
{{- end -}}
{{- end -}}

{{- define "ztm.networkPolicyProtocol" -}}
{{- $protocol := default "TCP" . | upper -}}
{{- if or (eq $protocol "UDP") (eq $protocol "SCTP") -}}
{{- $protocol -}}
{{- else -}}
TCP
{{- end -}}
{{- end -}}

{{- define "ztm.workloadNamespace" -}}
{{- $svc := .Values.serviceConfig | default (dict) -}}
{{- default .Release.Namespace (default $svc.namespace .Values.namespace) -}}
{{- end -}}

{{- define "ztm.workloadName" -}}
{{- $svc := .Values.serviceConfig | default (dict) -}}
{{- .Values.workload | default ($svc.workload | default .Release.Name) -}}
{{- end -}}

{{- define "ztm.workloadServiceAccount" -}}
{{- $svc := .Values.serviceConfig | default (dict) -}}
{{- default (include "ztm.workloadName" .) (.Values.serviceAccount | default $svc.serviceAccount) -}}
{{- end -}}

{{- define "ztm.targetPodLabels" -}}
{{- if .targetPodLabels -}}
{{- toYaml .targetPodLabels -}}
{{- else -}}
app.kubernetes.io/name: {{ .service }}
{{- end -}}
{{- end -}}

{{- define "ztm.labels" -}}
app.kubernetes.io/name: {{ include "ztm.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}
