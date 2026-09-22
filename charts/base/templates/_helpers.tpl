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
Name for optional namespace Role and RoleBinding (rbac.role).
*/}}
{{- define "base.rbac.roleName" -}}
{{- default (printf "%s-role" (include "base.fullname" .)) .Values.rbac.role.name }}
{{- end }}

{{/*
Kubernetes Role rules: from rbac.role.rules, or one rule built from rbac.role.apiGroups/resources/verbs.
*/}}
{{- define "base.rbac.roleRules" -}}
{{- $rules := .Values.rbac.role.rules }}
{{- if $rules }}
{{- toYaml $rules }}
{{- else if and (not (empty .Values.rbac.role.apiGroups)) (not (empty .Values.rbac.role.resources)) (not (empty .Values.rbac.role.verbs)) }}
{{- $rule := dict "apiGroups" .Values.rbac.role.apiGroups "resources" .Values.rbac.role.resources "verbs" .Values.rbac.role.verbs }}
{{- list $rule | toYaml }}
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

{{/*
Renders env variables with predefined items first so later variables can
reference them using Kubernetes env expansion syntax like $(POD_IP).
User-provided extraEnv can still override predefined items.
*/}}
{{- define "base.renderEnvVariables" -}}
{{- $root := .root -}}
{{- $extraEnv := default dict .extraEnv -}}
{{- $predefinedEnv := include "base.predefinedEnvVariables" $root | fromYaml -}}
{{- range $key, $value := $predefinedEnv }}
{{- $renderValue := $value -}}
{{- if hasKey $extraEnv $key }}
  {{- $renderValue = index $extraEnv $key -}}
{{- end }}
- name: {{ $key | quote }}
  {{- if kindIs "map" $renderValue }}
  valueFrom: {{ toYaml (ternary $renderValue $renderValue.valueFrom (empty ($renderValue).valueFrom)) | nindent 4 }}
  {{- else }}
  value: {{ $renderValue | quote }}
  {{- end }}
{{- end }}
{{- range $key, $value := $extraEnv }}
{{- if not (hasKey $predefinedEnv $key) }}
- name: {{ $key | quote }}
  {{- if kindIs "map" $value }}
  valueFrom: {{ toYaml (ternary $value $value.valueFrom (empty ($value).valueFrom)) | nindent 4 }}
  {{- else }}
  value: {{ $value | quote }}
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
PodDisruptionBudget safety helpers.

A PodDisruptionBudget that permits zero voluntary evictions blocks every
drain-based operation: node consolidation, reclaimed-capacity replacement, and
managed node group upgrades, which fail on pod eviction. The failure surfaces as
the node scaling or the cluster upgrade being stuck, far from the workload that
caused it. These helpers make that configuration unrepresentable.
*/}}

{{/* Primary's replica floor under flagger. rollout-strategy.yaml includes this same helper so the two
     cannot drift; `default` (not hasKey) because that is what the Canary does, 0 included. */}}
{{- define "base.primaryFloor" -}}
{{- $as := .Values.autoscaling | default dict -}}
{{- $cfg := (.Values.rolloutStrategy | default dict).configs | default dict -}}
{{- if $as.enabled -}}
{{- $cfg.primaryScalerMinReplicas | default $as.minReplicas | default 1 | int64 -}}
{{- else -}}
{{- if hasKey .Values "replicaCount" }}{{ .Values.replicaCount | int64 }}{{ else }}1{{ end -}}
{{- end -}}
{{- end -}}

{{- define "base.pdb.flagger" -}}
{{- $rs := .Values.rolloutStrategy | default dict -}}
{{- if and $rs.enabled (eq ($rs.operator | default "") "flagger") -}}true{{- end -}}
{{- end -}}

{{/* Replicas the budget is measured against. */}}
{{- define "base.pdb.floor" -}}
{{- $as := .Values.autoscaling | default dict -}}
{{- if include "base.pdb.flagger" . -}}
{{- include "base.primaryFloor" . -}}
{{- else if $as.enabled -}}
{{- if hasKey $as "minReplicas" }}{{ $as.minReplicas | int64 }}{{ else }}1{{ end -}}
{{- else -}}
{{- if hasKey .Values "replicaCount" }}{{ .Values.replicaCount | int64 }}{{ else }}1{{ end -}}
{{- end -}}
{{- end -}}

{{/* Which value supplied the floor -- named in errors because three can. */}}
{{- define "base.pdb.floorSource" -}}
{{- $as := .Values.autoscaling | default dict -}}
{{- if not $as.enabled -}}replicaCount
{{- else if and (include "base.pdb.flagger" .) (hasKey ((.Values.rolloutStrategy | default dict).configs | default dict) "primaryScalerMinReplicas") -}}rolloutStrategy.configs.primaryScalerMinReplicas
{{- else -}}autoscaling.minReplicas
{{- end -}}
{{- end -}}

{{- define "base.pdb.defaultMaxUnavailable" -}}25%{{- end -}}

{{/* Which of the two mutually exclusive fields applies. */}}
{{- define "base.pdb.field" -}}
{{- $pdb := .Values.pdb | default dict -}}
{{- ternary "minAvailable" "maxUnavailable" (and (hasKey $pdb "minAvailable") (not (kindIs "invalid" $pdb.minAvailable))) -}}
{{- end -}}

{{/* Evictions permitted. Budget percentages round UP on BOTH fields, so only 0% reaches zero. */}}
{{- define "base.pdb.permitted" -}}
{{- $v := toString .value -}}
{{- $n := ternary (int (ceil (divf (mulf (float64 (trimSuffix "%" $v)) (float64 .floor)) 100.0))) (int64 $v) (hasSuffix "%" $v) -}}
{{- ternary (sub .floor $n) $n (eq .field "minAvailable") -}}
{{- end -}}

{{/* The value that field carries, or the default. hasKey, not `default`: sprig's `get` returns "" for a
     missing key, and an explicit 0 is falsy -- both would silently become the default. */}}
{{- define "base.pdb.value" -}}
{{- $pdb := .Values.pdb | default dict -}}
{{- $f := include "base.pdb.field" . -}}
{{- $v := ternary (get $pdb $f) (include "base.pdb.defaultMaxUnavailable" .) (and (hasKey $pdb $f) (not (kindIs "invalid" (get $pdb $f)))) -}}
{{- /* %.0f, not toString: a large unquoted integer arrives as float64 and renders as 1e+06, which int64
       then coerces to 0 -- the guard then sees a budget permitting everything and renders one permitting
       nothing. Fractional floats never reach here; validate refuses them on the typed value first. */ -}}
{{- ternary (printf "%.0f" (float64 $v)) (toString $v) (kindIs "float64" $v) -}}
{{- end -}}

{{/* What this release's budget would permit. The one answer used to reject, to annotate and to render --
     three sites computed it separately before, and they had to agree. */}}
{{- define "base.pdb.allowed" -}}
{{- include "base.pdb.permitted" (dict "floor" (int (include "base.pdb.floor" .)) "field" (include "base.pdb.field" .) "value" (include "base.pdb.value" .)) -}}
{{- end -}}

{{- define "base.pdb.validate" -}}
{{- $pdb := .Values.pdb | default dict -}}
{{- $floor := int (include "base.pdb.floor" .) -}}
{{- $src := include "base.pdb.floorSource" . -}}
{{- if not (and (hasKey $pdb "enabled") (eq (include "base.toBool" $pdb.enabled) "false")) -}}

{{- if and (hasKey $pdb "minAvailable") (not (kindIs "invalid" $pdb.minAvailable)) (hasKey $pdb "maxUnavailable") (not (kindIs "invalid" $pdb.maxUnavailable)) -}}
{{- fail "base chart: pdb.minAvailable and pdb.maxUnavailable are mutually exclusive; set exactly one." -}}
{{- end -}}

{{- if and (include "base.pdb.renders" .) (include "base.pdb.flagger" .) (not $pdb.selectorOverride) (not (include "base.pdb.flaggerSelectorKey" .)) -}}
{{- fail "base chart: flagger is enabled but the selector holds none of `app`, `name`, `app.kubernetes.io/name`, so the label flagger suffixes on the primary cannot be derived. Set pdb.selectorOverride to the primary's real selector, or pdb.enabled=false." -}}
{{- end -}}

{{- if and (hasKey $pdb "enabled") (eq (include "base.toBool" $pdb.enabled) "true") (lt $floor 2) -}}
{{- fail (printf "base chart: pdb.enabled=true but the replica floor is %d (from %s). A budget over a single replica either blocks every drain or protects nothing. Raise the replica floor to 2 or more, or remove pdb.enabled." $floor $src) -}}
{{- end -}}

{{- if ge $floor 2 -}}
{{- $field := include "base.pdb.field" . -}}
{{- /* Typed, unlike base.pdb.value, because validateDomain must see a float64 as a float64. */ -}}
{{- $raw := include "base.pdb.defaultMaxUnavailable" . -}}
{{- if and (hasKey $pdb $field) (not (kindIs "invalid" (get $pdb $field))) -}}{{- $raw = get $pdb $field -}}{{- end -}}
{{- include "base.pdb.validateDomain" (dict "field" $field "value" $raw) -}}
{{- if and (le (int (include "base.pdb.allowed" .)) 0) (ne (include "base.toBool" $pdb.allowZeroEvictions) "true") -}}
{{- if hasSuffix "%" (toString $raw) -}}
{{- fail (printf "base chart: pdb.%s=%s permits no voluntary eviction at replica floor %d (from %s). Budget percentages round UP, so only 0%% can resolve to nothing. Set an absolute value, or a percentage above 0%%. If this workload is rolled by hand on purpose and must never be evicted automatically, set pdb.allowZeroEvictions=true to say so." $field (toString $raw) $floor $src) -}}
{{- else -}}
{{- fail (printf "base chart: pdb.%s=%s permits no voluntary eviction at replica floor %d (from %s). A budget that permits nothing blocks node drains, node consolidation and cluster upgrades. Set pdb.minAvailable below %d, or use pdb.maxUnavailable of 1 or more. If this workload is rolled by hand on purpose and must never be evicted automatically, set pdb.allowZeroEvictions=true to say so." $field (toString $raw) $floor $src $floor) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- end -}}
{{- end -}}

{{/* A zero-eviction budget the author asked for. base.pdb.renders already guarantees floor >= 2. */}}
{{- define "base.pdb.isDeliberatelyBlocking" -}}
{{- if and (include "base.pdb.renders" .) (eq (include "base.toBool" (.Values.pdb | default dict).allowZeroEvictions) "true") (le (int (include "base.pdb.allowed" .)) 0) -}}true{{- end -}}
{{- end -}}

{{/* Helm values carry booleans as bool or string, and "false" is truthy in a template. Aliases are
     accepted because --set-string yields them; anything else FAILS rather than defaulting to false, which
     would silently disable a budget the author asked for. */}}
{{- define "base.toBool" -}}
{{- if kindIs "invalid" . -}}false
{{- else if kindIs "bool" . -}}{{ ternary "true" "false" . }}
{{- else if kindIs "string" . -}}
  {{- if has (lower .) (list "true" "yes" "on" "1") -}}true
  {{- else if has (lower .) (list "false" "no" "off" "0" "") -}}false
  {{- else -}}{{- fail (printf "base chart: expected a boolean, got the string %q. Quote-free true/false, or drop --set-string for this key." .) -}}
  {{- end -}}
{{- else -}}{{- fail (printf "base chart: expected a boolean, got %s" (kindOf .)) -}}
{{- end -}}
{{- end -}}

{{- define "base.pdb.mayAutoCreate" -}}
{{- if and (eq (.Values.workloadType | default "Deployment") "Deployment") (not .Values.selectorLabelsOverride) -}}true{{- end -}}
{{- end -}}

{{/* Exactly what deployment.yaml puts in spec.selector.matchLabels: base.selectorLabels PLUS matchLabels. */}}
{{- define "base.pdb.targetSelector" -}}
{{- $sel := fromYaml (include "base.selectorLabels" .) -}}
{{- range $k, $v := (.Values.matchLabels | default dict) -}}
  {{- $_ := set $sel $v.name (toString $v.value) -}}
{{- end -}}
{{ toYaml $sel }}
{{- end -}}

{{/* Flagger suffixes the FIRST of its -selector-labels present in the selector, not a fixed key. Order is
     flagger's controller-wide default; a non-default controller needs pdb.selectorOverride. */}}
{{- define "base.pdb.flaggerSelectorKey" -}}
{{- $sel := fromYaml (include "base.pdb.targetSelector" .) -}}
{{- range $k := list "app" "name" "app.kubernetes.io/name" -}}
{{- if hasKey $sel $k -}}{{ $k }}{{- break -}}{{- end -}}
{{- end -}}
{{- end -}}

{{/* Under flagger the budget must select the generated primary: the canary is scaled to zero between
     rollouts, so a budget on the canary selector protects nothing while looking like protection. */}}
{{- define "base.pdb.selectorLabels" -}}
{{- $pdb := .Values.pdb | default dict -}}
{{- if $pdb.selectorOverride -}}
{{ $pdb.selectorOverride | toYaml }}
{{- else if include "base.pdb.flagger" . -}}
{{- $sel := fromYaml (include "base.pdb.targetSelector" .) -}}
{{- $key := include "base.pdb.flaggerSelectorKey" . -}}
{{- $out := dict -}}
{{- range $k, $v := $sel -}}
  {{- $_ := set $out $k (ternary (printf "%s-primary" $v) $v (eq $k $key)) -}}
{{- end -}}
{{ toYaml $out }}
{{- else -}}
{{- include "base.selectorLabels" . }}
{{- end -}}
{{- end -}}

{{/* Keep values inside the IntOrString domain. Arithmetic coercion otherwise accepts "150%", and "-1" or
     "abc" become 0 and then fail blaming the replica count. Args: dict "field" <name> "value" <any>. */}}
{{- define "base.pdb.validateDomain" -}}
{{- $field := .field -}}
{{- if kindIs "float64" .value -}}
{{- if ne (float64 .value) (floor (float64 .value)) -}}
{{- fail (printf "base chart: pdb.%s=%v is fractional. The Kubernetes IntOrString type holds a whole number or a percentage string, so this is refused here at render time -- rendering it would only move the same failure to apply time, where it is harder to place." $field .value) -}}
{{- end -}}
{{- end -}}
{{- /* A large unquoted integer arrives as a float and toString renders it in scientific notation, so
       format first -- the message must describe what was written. */ -}}
{{- $raw := ternary (printf "%.0f" (float64 .value)) (toString .value) (kindIs "float64" .value) -}}
{{- /* Checked by PATTERN, not by converting: `int` narrows, so a huge percentage overflows to 0 and would
       sail past a `> 100` comparison. */ -}}
{{- if hasSuffix "%" $raw -}}
{{- if not (regexMatch "^(100|[0-9]{1,2})%$" $raw) -}}
{{- fail (printf "base chart: pdb.%s=%s is not a percentage between 0%% and 100%%. A budget cannot describe more replicas than exist." $field $raw) -}}
{{- end -}}
{{- else -}}
{{- if not (regexMatch "^[0-9]{1,18}$" $raw) -}}
{{- fail (printf "base chart: pdb.%s=%s is neither a non-negative whole number nor a percentage. The Kubernetes API accepts only those two forms." $field $raw) -}}
{{- end -}}
{{- if gt (int64 $raw) 2147483647 -}}
{{- fail (printf "base chart: pdb.%s=%s exceeds the int32 maximum the Kubernetes IntOrString type can hold." $field $raw) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Whether a budget is rendered at all. Used by pdb.yaml and by NOTES.txt, so a warning without a budget
     is inexpressible. */}}
{{- define "base.pdb.renders" -}}
{{- $pdb := .Values.pdb | default dict -}}
{{- $explicit := and (hasKey $pdb "enabled") (eq (include "base.toBool" $pdb.enabled) "true") -}}
{{- $auto := and (not (hasKey $pdb "enabled")) (include "base.pdb.mayAutoCreate" .) -}}
{{- if and (or $explicit $auto) (ge (int (include "base.pdb.floor" .)) 2) -}}true{{- end -}}
{{- end -}}
