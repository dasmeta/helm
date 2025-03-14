{{/*
The docker registry auth resources names.
*/}}
{{- define "docker.auth.name" -}}
{{- .Values.dockerAuth.name | trunc 63 | trimSuffix "-" }}
{{- end }}
