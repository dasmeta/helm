{{/*
Expand the name of the chart.
*/}}
{{- define "base.name" -}}
{{- default .Chart.Name .Values.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "base.fullname" -}}
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

{{- define "base.version" -}}
{{- default .Chart.Version .Values.version | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "base.appVersion" -}}
{{- default .Chart.AppVersion .Values.appVersion | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "base.chart" -}}
{{- printf "%s-%s" (include "base.name" .) (include "base.version" .) | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "base.labels" -}}
helm.sh/chart: {{ include "base.chart" . }}
{{ include "base.selectorLabels" . }}
app.kubernetes.io/version: {{ include "base.appVersion" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "base.selectorLabels" -}}
{{- if .Values.selectorLabelsOverride -}}
{{ .Values.selectorLabelsOverride | toYaml }}
{{- else -}}
app.kubernetes.io/name: {{ include "base.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "base.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "base.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the target/server Kubernetes version
*/}}
{{- define "base.capabilities.kubeVersion" -}}
{{- default .Capabilities.KubeVersion.Version .Values.kubeVersion -}}
{{- end -}}

{{- define "annotations" -}}
{{- $ingressAnnotations := .annotations -}}

{{- if eq .class "alb" }}
{{- $defaultAnnotations := dict "kubernetes.io/ingress.class" "alb"
                    "alb.ingress.kubernetes.io/target-type" "ip"
                    "alb.ingress.kubernetes.io/scheme" "internet-facing"
                    "alb.ingress.kubernetes.io/group.order" "20"
                    "alb.ingress.kubernetes.io/healthcheck-path" "/"
                    "alb.ingress.kubernetes.io/listen-ports" "[{\"HTTP\":80},{\"HTTPS\":443}]"
                    "alb.ingress.kubernetes.io/success-codes" "200-399" -}}
{{- $mergedAnnotations := merge $ingressAnnotations $defaultAnnotations -}}
{{- $mergedAnnotations | toYaml }}
{{- else if eq .class "application-gateway" }}
{{- $defaultAnnotations := dict "kubernetes.io/ingress.class" "azure/application-gateway"
                    "external-dns.alpha.kubernetes.io/ttl" "60"
                    "appgw.ingress.kubernetes.io/backend-protocol" "http"
                    "appgw.ingress.kubernetes.io/ssl-redirect" "true" -}}
{{- $mergedAnnotations := merge $defaultAnnotations $ingressAnnotations -}}
{{- $mergedAnnotations | toYaml }}
{{- else if eq .class "cce" }}
{{- $defaultAnnotations := dict "kubernetes.io/ingress.class" "cce"
                    "kubernetes.io/elb.port" "443" -}}
{{- $mergedAnnotations := merge $ingressAnnotations $defaultAnnotations -}}
{{- $mergedAnnotations | toYaml }}
{{- else }}
{{- $defaultAnnotations := (ternary ("{}" | fromYaml) (dict "kubernetes.io/ingress.class" .class) .Values.setIngressClassByField) -}}
{{- $mergedAnnotations := merge $ingressAnnotations $defaultAnnotations -}}
{{- $mergedAnnotations | toYaml }}
{{- end }}
{{- end }}

{{/*
Returns extraContainers list as yaml
*/}}
{{- define "base.extraContainers" -}}
{{- (dict "data" (concat (ternary $.Values.extraContainer (list $.Values.extraContainer) (kindIs "slice" $.Values.extraContainer)) (ternary $.Values.extraContainers (list $.Values.extraContainers) (kindIs "slice" $.Values.extraContainers)))) | toYaml -}}
{{- end -}}


{{/*
Returns env/volume config maps object/dict as yaml
*/}}
{{- define "base.configs" -}}
{{- (merge $.Values.config $.Values.configs) | toYaml -}}
{{- end -}}

{{/*
Returns env config maps object/dict as yaml
*/}}
{{- define "base.envConfigs" -}}
{{- $configs := fromYaml (include "base.configs" $) }}
{{- $envConfigs := dict -}}
{{- range $key, $value := $configs -}}
  {{- if not (hasPrefix "/" $key) -}}
    {{- $envConfigs = merge $envConfigs (dict $key $value) -}}
  {{- end -}}
{{- end -}}
{{- $envConfigs | toYaml -}}
{{- end -}}

{{/*
Returns volume config maps object/dict as yaml
*/}}
{{- define "base.volumeConfigs" -}}
{{- $configs := fromYaml (include "base.configs" $) }}
{{- $volumeConfigs := dict -}}
{{- range $key, $value := $configs -}}
  {{- if hasPrefix "/" $key -}}
    {{- $volumeConfigs = merge $volumeConfigs (dict $key $value) -}}
  {{- end -}}
{{- end -}}
{{- $volumeConfigs | toYaml -}}
{{- end -}}

{{/*
Returns config map volume configs object/dict as yaml
*/}}
{{- define "base.configMapVolumes" -}}
{{- $configMapVolumes := list -}}
{{- range $folder, $files := fromYaml (include "base.volumeConfigs" $) -}}
  {{- if ne (kindOf $files) "string" -}}
    {{- $configMapVolumes = append $configMapVolumes (dict "name" (trimPrefix "-" (trimSuffix "-" (replace "/" "-"  (replace "." "-" $folder)))) "configMap" (dict "name" (printf "%s-%s" (include "base.fullname" $) (trimPrefix "-" (trimSuffix "-" (replace "/" "-"  (replace "." "-" $folder))))) "defaultMode" $.Values.defaultModeOfConfigMapSecretVolumes) "mountPath" $folder ) -}}
  {{- else -}}
    {{- $configMapVolumes = append $configMapVolumes (dict "name" (trimPrefix "-" (trimSuffix "-" (replace "/" "-"  (replace "." "-" $folder)))) "configMap" (dict "name" (printf "%s-%s" (include "base.fullname" $) (trimPrefix "-" (trimSuffix "-" (replace "/" "-"  (replace "." "-" $folder))))) "defaultMode" $.Values.defaultModeOfConfigMapSecretVolumes) "mountPath" $folder "subPath" (replace "/" "-" $folder) ) -}}
  {{- end -}}
{{- end -}}
{{- (dict "data" $configMapVolumes) | toYaml -}}
{{- end -}}

{{/*
Returns external secret data configs
*/}}
{{- define "base.externalSecrets" -}}
{{- $externalSecrets := list -}}
{{- range $secret := $.Values.secrets -}}
  {{- if eq (kindOf $secret) "string" }}
    {{- $externalSecrets = append $externalSecrets (dict "secretKey" (ternary (replace "/" "-" $secret) $secret (hasPrefix "/" $secret)) "property" $secret) -}}
  {{- else -}}
    {{- range $folder, $files := $secret -}}
      {{- if hasPrefix "/" $folder -}}
        {{- range $file := $files }}
          {{- $externalSecrets = append $externalSecrets (dict "secretKey" (replace "/" "-" (printf "%s/%s" (trimSuffix "/" $folder) (trimPrefix "/" $file))) "property" (printf "%s/%s" (trimSuffix "/" $folder) (trimPrefix "/" $file))) -}}
        {{- end }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- (dict "data" $externalSecrets) | toYaml -}}
{{- end -}}

{{/*
Returns secret volume configs object/dict as yaml
*/}}
{{- define "base.secretVolumes" -}}
{{- $secretVolumes := list -}}
{{- range $secret := $.Values.secrets -}}
  {{- if ne (kindOf $secret) "string" }}
    {{- range $folder, $files := $secret -}}
      {{- if hasPrefix "/" $folder }}
        {{- $secretItems:= list -}}
        {{- range $file := $files -}}
          {{- $secretItems = append $secretItems (dict "path" $file "key" (replace "/" "-" (printf "%s/%s" (trimSuffix "/" $folder) (trimPrefix "/" $file)))) -}}
        {{- end -}}
        {{- $secretVolumes = append $secretVolumes (dict "name" (trimPrefix "-" (trimSuffix "-" (replace "/" "-"  (replace "." "-" $folder)))) "secret" (dict "secretName" (include "base.fullname" $) "items" $secretItems "defaultMode" $.Values.defaultModeOfConfigMapSecretVolumes) "mountPath" $folder ) -}}
      {{- end -}}
    {{- end -}}
  {{- else if hasPrefix "/" $secret -}}
    {{- $secretVolumes = append $secretVolumes (dict "name" (trimPrefix "-" (trimSuffix "-" (replace "/" "-"  (replace "." "-" $secret)))) "secret" (dict "secretName" (include "base.fullname" $) "defaultMode" $.Values.defaultModeOfConfigMapSecretVolumes) "mountPath" $secret "subPath" (replace "/" "-" $secret) ) -}}
  {{- end -}}
{{- end -}}
{{- (dict "data" $secretVolumes) | toYaml -}}
{{- end -}}


{{/*
Returns extraContainers env/volume config maps object/dict as yaml
*/}}
{{- define "base.extraContainersConfigs" -}}
{{- $extraContainersConfigs := dict -}}
{{- range $extraContainer := (fromYaml (include "base.extraContainers" $)).data }}
  {{- $extraContainersConfigs = merge $extraContainersConfigs (dict $extraContainer.name $extraContainer.configs) -}}
{{- end -}}
{{- $extraContainersConfigs | toYaml -}}
{{- end -}}

{{/*
Returns extraContainers env config maps object/dict as yaml
*/}}
{{- define "base.extraContainersEnvConfigs" -}}
{{- $extraContainersConfigs := fromYaml (include "base.extraContainersConfigs" $) }}
{{- $envConfigs := dict -}}
{{- range $container, $configs := $extraContainersConfigs -}}
  {{- $containerEnvConfigs := dict -}}
  {{- range $key, $value := $configs -}}
    {{- if not (hasPrefix "/" $key) -}}
      {{- $containerEnvConfigs = merge $containerEnvConfigs (dict $key $value) -}}
    {{- end -}}
  {{- end -}}
  {{- $envConfigs = merge $envConfigs (dict $container $containerEnvConfigs) -}}
{{- end -}}
{{- $envConfigs | toYaml -}}
{{- end -}}

{{/*
Returns extraContainers volume config maps object/dict as yaml
*/}}
{{- define "base.extraContainersVolumeConfigs" -}}
{{- $extraContainersConfigs := fromYaml (include "base.extraContainersConfigs" $) }}
{{- $volumeConfigs := dict -}}
{{- range $container, $configs := $extraContainersConfigs -}}
  {{- $containerVolumeConfigs := dict -}}
  {{- range $key, $value := $configs -}}
    {{- if hasPrefix "/" $key -}}
      {{- $containerVolumeConfigs = merge $containerVolumeConfigs (dict $key $value) -}}
    {{- end -}}
  {{- end -}}
  {{- $volumeConfigs = merge $volumeConfigs (dict $container $containerVolumeConfigs) -}}
{{- end -}}
{{- $volumeConfigs | toYaml -}}
{{- end -}}

{{/*
Returns extraContainers config map volume configs object/dict as yaml
*/}}
{{- define "base.extraContainersConfigMapVolumes" -}}
{{- $configMapVolumes := list -}}
{{- range $container, $configs := fromYaml (include "base.extraContainersVolumeConfigs" $) -}}
  {{- range $folder, $files := $configs -}}
    {{- if ne (kindOf $files) "string" -}}
      {{- $configMapVolumes = append $configMapVolumes (dict "name" (trimPrefix "-" (trimSuffix "-" (replace "/" "-"  (replace "." "-" (printf "%s%s" $container $folder))))) "configMap" (dict "name" (printf "%s-%s-%s" (include "base.fullname" $) $container (trimPrefix "-" (trimSuffix "-" (replace "/" "-"  (replace "." "-" $folder))))) "defaultMode" $.Values.defaultModeOfConfigMapSecretVolumes) "mountPath" $folder "container" $container ) -}}
    {{- else -}}
      {{- $configMapVolumes = append $configMapVolumes (dict "name" (trimPrefix "-" (trimSuffix "-" (replace "/" "-"  (replace "." "-" (printf "%s%s" $container $folder))))) "configMap" (dict "name" (printf "%s-%s-%s" (include "base.fullname" $) $container (trimPrefix "-" (trimSuffix "-" (replace "/" "-"  (replace "." "-" $folder))))) "defaultMode" $.Values.defaultModeOfConfigMapSecretVolumes) "mountPath" $folder "subPath" (replace "/" "-" $folder) "container" $container ) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- (dict "data" $configMapVolumes) | toYaml -}}
{{- end -}}

{{/*
Returns extraContainers external secret data configs
*/}}
{{- define "base.extraContainersExternalSecrets" -}}
{{- $externalSecrets := list -}}
{{- range $extraContainer := (fromYaml (include "base.extraContainers" $)).data }}
  {{- $container := $extraContainer.name -}}
  {{- range $secret := $extraContainer.secrets -}}
    {{- if eq (kindOf $secret) "string" }}
      {{- $externalSecrets = append $externalSecrets (dict "secretKey" (printf "%s-%s" $container (ternary (replace "/" "-" $secret) $secret (hasPrefix "/" $secret))) "property" (printf "%s-%s" $container $secret)) -}}
    {{- else -}}
      {{- range $folder, $files := $secret -}}
        {{- if hasPrefix "/" $folder -}}
          {{- range $file := $files }}
            {{- $externalSecrets = append $externalSecrets (dict "secretKey" (printf "%s-%s" $container (replace "/" "-" (printf "%s/%s" (trimSuffix "/" $folder) (trimPrefix "/" $file)))) "property" (printf "%s-%s/%s" $container (trimSuffix "/" $folder) (trimPrefix "/" $file))) -}}
          {{- end }}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- (dict "data" $externalSecrets) | toYaml -}}
{{- end -}}

{{/*
Returns extraContainers secret volume configs object/dict as yaml
*/}}
{{- define "base.extraContainersSecretVolumes" -}}
{{- $secretVolumes := list -}}
{{- range $extraContainer := (fromYaml (include "base.extraContainers" $)).data }}
  {{- $container := $extraContainer.name -}}
  {{- range $secret := $extraContainer.secrets -}}
    {{- if ne (kindOf $secret) "string" }}
      {{- range $folder, $files := $secret -}}
        {{- if hasPrefix "/" $folder }}
          {{- $secretItems:= list -}}
          {{- range $file := $files -}}
            {{- $secretItems = append $secretItems (dict "path" $file "key" (printf "%s-%s" $container (replace "/" "-" (printf "%s/%s" (trimSuffix "/" $folder) (trimPrefix "/" $file))))) -}}
          {{- end -}}
          {{- $secretVolumes = append $secretVolumes (dict "name" (printf "%s-%s" $container (trimPrefix "-" (trimSuffix "-" (replace "/" "-"  (replace "." "-" $folder))))) "secret" (dict "secretName" (include "base.fullname" $) "items" $secretItems "defaultMode" $.Values.defaultModeOfConfigMapSecretVolumes) "mountPath" $folder "container" $container ) -}}
        {{- end -}}
      {{- end -}}
    {{- else if hasPrefix "/" $secret -}}
      {{- $secretVolumes = append $secretVolumes (dict "name" (printf "%s-%s" $container (trimPrefix "-" (trimSuffix "-" (replace "/" "-"  (replace "." "-" $secret))))) "secret" (dict "secretName" (include "base.fullname" $) "defaultMode" $.Values.defaultModeOfConfigMapSecretVolumes) "mountPath" $secret "subPath" (replace "/" "-" $secret) "container" $container ) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- (dict "data" $secretVolumes) | toYaml -}}
{{- end -}}

{{/*
Returns predefined list of env variables to pass to all containers
*/}}
{{- define "base.predefinedEnvVariables" -}}
HELM_CHART_NAME: {{ .Chart.Name }}
HELM_CHART_VERSION: {{ .Chart.Version }}
HELM_CHART_APP_VERSION: {{ .Chart.AppVersion }}
HELM_RELEASE_NAME: {{ .Release.Name }}
POD_IP:
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
{{- end -}}
