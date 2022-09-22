{{/* Helm standard labels */}}
{{- define "weave-scope-frontend.helm_std_labels" }}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
app: {{ template "toplevel.name" . }}
{{- end }}

*/ -}}
{{- define "chartmuseum.name"}}
{{- $global := default (dict) .Values.global -}}
{{- $base := default .Chart.Name .Values.nameOverride -}}
{{- $gpre := default "" $global.namePrefix -}}
{{- $pre := default "" .Values.namePrefix -}}
{{- $suf := default "" .Values.nameSuffix -}}
{{- $gsuf := default "" $global.nameSuffix -}}
{{- $name := print $gpre $pre $base $suf $gsuf -}}
{{- $name | lower | trunc 54 | trimSuffix "-" -}}
{{- end -}}

{{- /*

*/ -}}
{{- define "chartmuseum.fullname"}}
{{- $global := default (dict) .Values.global -}}
{{- $base := default (printf "%s-%s" .Release.Name .Chart.Name) .Values.fullnameOverride -}}
{{- $gpre := default "" $global.fullnamePrefix -}}
{{- $pre := default "" .Values.fullnamePrefix -}}
{{- $suf := default "" .Values.fullnameSuffix -}}
{{- $gsuf := default "" $global.fullnameSuffix -}}
{{- $name := print $gpre $pre $base $suf $gsuf -}}
{{- $name | lower | trunc 54 | trimSuffix "-" -}}
{{- end -}}


{{- define "chartmuseum.labels.standard" -}}
app: {{ template "chartmuseum.name" . }}
chart: {{ template "chartmuseum.chartref" . }}
heritage: {{ .Release.Service | quote }}
release: {{ .Release.Name | quote }}
{{- end -}}

{{- define "chartmuseum.chartref" -}}
{{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end -}}


{{/* Weave Scope default annotations */}}
{{- define "weave-scope-frontend.annotations" }}
cloud.weave.works/launcher-info: |-
  {
    "server-version": "master-4fe8efe",
    "original-request": {
      "url": "/k8s/v1.7/scope.yaml"
    },
    "email-address": "support@weave.works",
    "source-app": "weave-scope",
    "weave-cloud-component": "scope"
  }
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "weave-scope-frontend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the top-level chart.
*/}}
{{- define "toplevel.name" -}}
{{- default (.Template.BasePath | split "/" )._0 .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.  We truncate at 63 chars.
*/}}
{{- define "weave-scope-frontend.fullname" -}}
{{- printf "%s-%s" .Chart.Name .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified name that always uses the name of the top-level chart.
*/}}
{{- define "toplevel.fullname" -}}
{{- $name := default (.Template.BasePath | split "/" )._0 .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
