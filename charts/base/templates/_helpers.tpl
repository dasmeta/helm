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

{{/* Which value the effective replica floor was taken from, for error messages. */}}
{{- define "base.pdb.flagger" -}}
{{- $rs := .Values.rolloutStrategy | default dict -}}
{{- if and $rs.enabled (eq ($rs.operator | default "") "flagger") -}}true{{- end -}}
{{- end -}}

{{- define "base.pdb.floorSource" -}}
{{- if include "base.pdb.flagger" . -}}
rolloutStrategy.configs.primaryScalerMinReplicas
{{- else -}}
{{- if (.Values.autoscaling | default dict).enabled -}}
autoscaling.minReplicas
{{- else -}}
replicaCount
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
The effective replica floor: the smallest replica count the workload is expected
to run at. When autoscaling is on, the deployment omits `replicas` entirely and
the autoscaler minimum is the only lower bound, so that is the number to use.
Coerced through int64 because values may arrive as strings, where a lexical
comparison would rank "10" below "2".
*/}}
{{- define "base.pdb.floor" -}}
{{- $as := .Values.autoscaling | default dict -}}
{{- if include "base.pdb.flagger" . -}}
{{- /* Under flagger the canary deployment is scaled to zero between rollouts and the generated `-primary`
       is what serves traffic, so the primary's autoscaler minimum is the floor that matters. Flagger
       defaults it to autoscaling.minReplicas when primaryScalerMinReplicas is unset, and so does this. */ -}}
{{- $cfg := (.Values.rolloutStrategy.configs | default dict) -}}
{{- if hasKey $cfg "primaryScalerMinReplicas" }}{{ $cfg.primaryScalerMinReplicas | int64 }}
{{- else if hasKey $as "minReplicas" }}{{ $as.minReplicas | int64 }}{{ else }}1{{ end -}}
{{- else if $as.enabled -}}
{{- if hasKey $as "minReplicas" }}{{ $as.minReplicas | int64 }}{{ else }}1{{ end -}}
{{- else -}}
{{- if hasKey .Values "replicaCount" }}{{ .Values.replicaCount | int64 }}{{ else }}1{{ end -}}
{{- end -}}
{{- end -}}

{{/*
Evictions a budget permits at the effective replica floor, following the rounding the DISRUPTION
controller actually uses: it resolves BOTH minAvailable and maxUnavailable percentages with roundUp=true
(pkg/controller/disruption/disruption.go). This is not the same as a Deployment rolling update, where
maxUnavailable rounds DOWN -- mixing the two up rejects safe configurations, because "25%" of 2 is 1
permitted eviction under PDB rules and 0 under rollout rules.
Args: dict "floor" <int> "field" <minAvailable|maxUnavailable> "value" <any>
*/}}
{{- define "base.pdb.permitted" -}}
{{- $floorVal := .floor -}}
{{- $field := .field -}}
{{- $value := .value -}}
{{- if hasSuffix "%" (toString $value) -}}
  {{- $pct := float64 (trimSuffix "%" (toString $value)) -}}
  {{- $raw := divf (mulf $pct (float64 $floorVal)) 100.0 -}}
  {{- if eq $field "minAvailable" -}}
    {{- sub $floorVal (int (ceil $raw)) -}}
  {{- else -}}
    {{- int (ceil $raw) -}}
  {{- end -}}
{{- else -}}
  {{- if eq $field "minAvailable" -}}
    {{- sub $floorVal (int64 $value) -}}
  {{- else -}}
    {{- int64 $value -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Refuse any budget that permits zero voluntary evictions. Called unconditionally
from pdb.yaml, before the enabled check, because the most dangerous case is the
one where no budget would be rendered at all: a budget explicitly enabled at a
replica floor below 2.
*/}}
{{- define "base.pdb.validate" -}}
{{- $pdb := .Values.pdb | default dict -}}
{{- $floorVal := int (include "base.pdb.floor" .) -}}
{{- $src := include "base.pdb.floorSource" . -}}
{{- $hasMin := and (hasKey $pdb "minAvailable") (not (kindIs "invalid" $pdb.minAvailable)) -}}
{{- $hasMax := and (hasKey $pdb "maxUnavailable") (not (kindIs "invalid" $pdb.maxUnavailable)) -}}
{{- $explicitlyDisabled := and (hasKey $pdb "enabled") (eq (include "base.toBool" $pdb.enabled) "false") -}}
{{- /* Deliberate opt-in to a budget that permits nothing. See values.yaml for when this is legitimate. */ -}}
{{- $allowBlocking := eq (include "base.toBool" $pdb.allowZeroEvictions) "true" -}}
{{- if not $explicitlyDisabled -}}

  {{- if and $hasMin $hasMax -}}
    {{- fail "base chart: pdb.minAvailable and pdb.maxUnavailable are mutually exclusive; the Kubernetes PodDisruptionBudget API accepts only one. Set exactly one of them." -}}
  {{- end -}}

  {{- if and (hasKey $pdb "enabled") (eq (include "base.toBool" $pdb.enabled) "true") (lt $floorVal 2) -}}
    {{- fail (printf "base chart: pdb.enabled=true but the replica floor is %d (from %s). A budget over a single replica either blocks every drain or protects nothing. Raise the replica floor to 2 or more, or remove pdb.enabled." $floorVal $src) -}}
  {{- end -}}

  {{- if ge $floorVal 2 -}}
    {{- $field := ternary "minAvailable" "maxUnavailable" $hasMin -}}
    {{- $value := include "base.pdb.defaultMaxUnavailable" . -}}
    {{- if $hasMin -}}{{- $value = $pdb.minAvailable -}}{{- else if $hasMax -}}{{- $value = $pdb.maxUnavailable -}}{{- end -}}
    {{- include "base.pdb.validateDomain" (dict "field" $field "value" $value) -}}
    {{- $permitted := int (include "base.pdb.permitted" (dict "floor" $floorVal "field" $field "value" $value)) -}}
    {{- if and (le $permitted 0) (not $allowBlocking) -}}
      {{- if hasSuffix "%" (toString $value) -}}
        {{- $rounding := ternary "up" "down" (eq $field "minAvailable") -}}
        {{- fail (printf "base chart: pdb.%s=%s resolves to 0 permitted evictions at replica floor %d (from %s), because Kubernetes rounds %s percentages %s. Set an absolute value, or choose a percentage that leaves at least one eviction. If this workload is rolled by hand on purpose and must never be evicted automatically, set pdb.allowZeroEvictions=true to say so." $field (toString $value) $floorVal $src $field $rounding) -}}
      {{- else -}}
        {{- fail (printf "base chart: pdb.%s=%s permits no voluntary eviction at replica floor %d (from %s). A budget that permits nothing blocks node drains, node consolidation and cluster upgrades. Set pdb.minAvailable below %d, or use pdb.maxUnavailable of 1 or more. If this workload is rolled by hand on purpose and must never be evicted automatically, set pdb.allowZeroEvictions=true to say so." $field (toString $value) $floorVal $src $floorVal) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

{{- end -}}
{{- end -}}

{{/*
Whether the rendered budget permits zero voluntary evictions AND the author opted into that deliberately.
Used by pdb.yaml to annotate the object and by NOTES.txt to warn on every install and upgrade. Returns
"true" or "".
*/}}
{{- define "base.pdb.isDeliberatelyBlocking" -}}
{{- $pdb := .Values.pdb | default dict -}}
{{- if eq (include "base.toBool" $pdb.allowZeroEvictions) "true" -}}
  {{- $floorVal := int (include "base.pdb.floor" .) -}}
  {{- if ge $floorVal 2 -}}
    {{- $hasMin := and (hasKey $pdb "minAvailable") (not (kindIs "invalid" $pdb.minAvailable)) -}}
    {{- $hasMax := and (hasKey $pdb "maxUnavailable") (not (kindIs "invalid" $pdb.maxUnavailable)) -}}
    {{- $field := ternary "minAvailable" "maxUnavailable" $hasMin -}}
    {{- $value := include "base.pdb.defaultMaxUnavailable" . -}}
    {{- if $hasMin -}}{{- $value = $pdb.minAvailable -}}{{- else if $hasMax -}}{{- $value = $pdb.maxUnavailable -}}{{- end -}}
    {{- if le (int (include "base.pdb.permitted" (dict "floor" $floorVal "field" $field "value" $value))) 0 -}}
true
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
The default maxUnavailable: "25%", at every replica floor.

A percentage rather than a number computed here, because kubernetes resolves it at RUNTIME against the
current expected pod count while a number is fixed at template time from the FLOOR and never moves. For
minReplicas 10 / maxReplicas 100 that is the whole difference: a number permits the same 2 evictions at 10
pods, 20 and 100, where "25%" gives 2, 5 and 25.

25% is what a Deployment rollout already does by default, so draining paces at a rate the service
demonstrably tolerates every time it is deployed.

It needs no lower boundary. The disruption controller rounds maxUnavailable percentages UP, so "25%" is 1
permitted eviction at a floor of 2 or 3, never 0. Only "0%" can resolve to zero.
*/}}
{{- define "base.pdb.defaultMaxUnavailable" -}}
25%
{{- end -}}

{{/*
Read a value as a boolean, refusing anything that is not one.

Go templates treat ANY non-empty string as true, so `--set-string pdb.allowZeroEvictions=false` -- or a
quoted "false" in a values file -- would otherwise authorise a zero-eviction budget and annotate it as
deliberate. A safety flag that turns on when you write "false" is worse than no flag. Returns "true",
"false", or fails.
*/}}
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

{{/*
Whether this release may create a PodDisruptionBudget WITHOUT being asked to.

Automatic creation is only safe where the chart owns both the workload and the selector. Three cases where
it does not, and an unrequested budget is wrong rather than merely useless:

  workloadType != Deployment  -- the workload template does not render, so the budget would select nothing.
  selectorLabelsOverride set  -- the release deliberately points at ANOTHER release's pods (see
                                 examples/base/with-second-deployment). Two releases would then render two
                                 budgets over the same pods, and the eviction API refuses to evict a pod
                                 covered by more than one PDB -- turning a feature meant to protect drains
                                 into one that blocks them outright.

Flagger IS handled rather than skipped: base.pdb.floor takes the primary's scaler minimum and
base.pdb.selectorLabels selects the generated `-primary`, so the budget lands on the workload that actually
serves traffic.

An explicit `pdb.enabled: true` still wins in both cases above: the author has taken ownership, and a budget
they asked for is their decision to make. Returns "true" or "".
*/}}
{{- define "base.pdb.mayAutoCreate" -}}
{{- if and (eq (.Values.workloadType | default "Deployment") "Deployment") (not .Values.selectorLabelsOverride) -}}
true
{{- end -}}
{{- end -}}

{{/*
The selector the budget must carry.

Normally the chart's own selector labels. Under flagger it has to be the GENERATED primary's instead: the
canary deployment is scaled to zero between rollouts, so a budget over the canary selector protects nothing
while looking like protection.

Flagger builds the primary's labels by taking the target deployment's selector and replacing the value of
each label it is configured to treat as the name -- its `-selector-labels` flag, which defaults to
`app,name,app.kubernetes.io/name`. This chart selects on `app.kubernetes.io/name`, which is in that default
set, so the primary carries `<fullname>-primary` there and keeps `app.kubernetes.io/instance` unchanged.

If a cluster runs flagger with a non-default `-selector-labels` that omits `app.kubernetes.io/name`, this
selector is wrong; set pdb.selectorOverride to whatever `kubectl get deploy <name>-primary -o jsonpath=
'{.spec.selector.matchLabels}'` actually reports there.
*/}}
{{- define "base.pdb.selectorLabels" -}}
{{- $pdb := .Values.pdb | default dict -}}
{{- if $pdb.selectorOverride -}}
{{ $pdb.selectorOverride | toYaml }}
{{- else if include "base.pdb.flagger" . -}}
app.kubernetes.io/name: {{ include "base.fullname" . }}-primary
app.kubernetes.io/instance: {{ .Release.Name }}
{{- else -}}
{{- include "base.selectorLabels" . }}
{{- end -}}
{{- end -}}

{{/*
Reject values outside the Kubernetes IntOrString domain for a disruption budget.

Without this, arithmetic coercion quietly accepts things the API server does not: "150%" renders straight
through, and "-1" or "abc" coerce to 0 and then fail with a message about permitting no evictions, which
blames the wrong thing and sends the reader looking for a replica-count problem. Worse, either would slip
past entirely under pdb.allowZeroEvictions.
Args: dict "field" <name> "value" <any>
*/}}
{{- define "base.pdb.validateDomain" -}}
{{- $field := .field -}}
{{- $raw := toString .value -}}
{{- if hasSuffix "%" $raw -}}
  {{- if not (regexMatch "^[0-9]+%$" $raw) -}}
    {{- fail (printf "base chart: pdb.%s=%s is not a valid percentage. Use a whole number followed by %%, for example \"25%%\"." $field $raw) -}}
  {{- end -}}
  {{- if gt (int (trimSuffix "%" $raw)) 100 -}}
    {{- fail (printf "base chart: pdb.%s=%s exceeds 100%%. A budget cannot describe more replicas than exist." $field $raw) -}}
  {{- end -}}
{{- else -}}
  {{- if not (regexMatch "^[0-9]+$" $raw) -}}
    {{- fail (printf "base chart: pdb.%s=%s is neither a non-negative whole number nor a percentage. The Kubernetes API accepts only those two forms." $field $raw) -}}
  {{- end -}}
{{- end -}}
{{- end -}}
