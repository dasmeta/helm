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
{{/*
The primary workload's replica floor under flagger, matching rollout-strategy.yaml EXACTLY.

The two must agree, so this is the single definition and the Canary template includes it. They previously
did not: this helper always preferred primaryScalerMinReplicas, while the Canary emits an autoscalerRef --
and therefore primaryScalerReplicas -- only when autoscaling is enabled. With autoscaling off,
replicaCount 3 and primaryScalerMinReplicas 5, flagger scales the primary to 3 while the budget believed 5,
so `pdb.minAvailable: 4` rendered against a 3-replica deployment: a budget requiring more pods than exist,
which can never permit an eviction and blocks every drain.

`default` is used rather than a hasKey check because that is what the Canary does, including its treatment
of 0 as absent. Matching it matters more than either behaviour in isolation.
*/}}
{{- define "base.primaryFloor" -}}
{{- $as := .Values.autoscaling | default dict -}}
{{- $cfg := (.Values.rolloutStrategy | default dict).configs | default dict -}}
{{- if $as.enabled -}}
{{- $cfg.primaryScalerMinReplicas | default $as.minReplicas | default 1 | int64 -}}
{{- else -}}
{{- /* No autoscalerRef is emitted, so flagger mirrors the deployment's static replica count. */ -}}
{{- if hasKey .Values "replicaCount" }}{{ .Values.replicaCount | int64 }}{{ else }}1{{ end -}}
{{- end -}}
{{- end -}}

{{- define "base.pdb.flagger" -}}
{{- $rs := .Values.rolloutStrategy | default dict -}}
{{- if and $rs.enabled (eq ($rs.operator | default "") "flagger") -}}true{{- end -}}
{{- end -}}

{{- define "base.pdb.floorSource" -}}
{{- if include "base.pdb.flagger" . -}}
{{- if not (.Values.autoscaling | default dict).enabled -}}
replicaCount, which is what flagger mirrors when autoscaling is disabled
{{- else if hasKey ((.Values.rolloutStrategy | default dict).configs | default dict) "primaryScalerMinReplicas" -}}
rolloutStrategy.configs.primaryScalerMinReplicas
{{- else -}}
autoscaling.minReplicas, which primaryScalerMinReplicas falls back to when unset
{{- end -}}
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
       is what serves traffic, so the primary's floor is the one that matters. */ -}}
{{- include "base.primaryFloor" . -}}
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

  {{- /* Flagger suffixes the first of its selector-labels present in the target's selector. If none is
         there, flagger itself refuses the canary and there is no correct selector to derive, so rendering
         one would produce a budget matching zero pods -- present, reporting no expected pods, protecting
         nothing. Refuse instead, and name the way out. */ -}}
  {{- /* Gated on whether a budget renders at all. Unconditional, this refused a working setup -- flagger
         plus selectorLabelsOverride and no pdb.enabled -- where the chart stands down and creates nothing,
         so there was no selector to get wrong and nothing to protect. */ -}}
  {{- if and (include "base.pdb.renders" .) (include "base.pdb.flagger" .) (not $pdb.selectorOverride) (not (include "base.pdb.flaggerSelectorKey" .)) -}}
    {{- fail "base chart: this release uses a flagger rolloutStrategy, but its selector labels contain none of `app`, `name` or `app.kubernetes.io/name`, so the label flagger will suffix on the generated primary cannot be derived. Set pdb.selectorOverride to the primary's real selector -- `kubectl get deploy <name>-primary -o jsonpath='{.spec.selector.matchLabels}'` reports it -- or set pdb.enabled=false." -}}
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
        {{- fail (printf "base chart: pdb.%s=%s resolves to 0 permitted evictions at replica floor %d (from %s). Budget percentages round UP, so only 0%% can resolve to nothing. Set an absolute value, or a percentage above 0. If this workload is rolled by hand on purpose and must never be evicted automatically, set pdb.allowZeroEvictions=true to say so." $field (toString $value) $floorVal $src) -}}
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
{{- /* Gated on the SAME render decision pdb.yaml makes. Without this the notes warn about a budget that was
       never created -- pdb.enabled=false with allowZeroEvictions=true told the reader their release had a
       zero-eviction budget when it had no budget at all. */ -}}
{{- if and (include "base.pdb.renders" .) (eq (include "base.toBool" $pdb.allowZeroEvictions) "true") -}}
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

Flagger does not suffix a fixed label. It walks its `-selector-labels` list IN ORDER -- default
`app,name,app.kubernetes.io/name` -- and suffixes the FIRST of those keys present in the target
deployment's selector, leaving the rest untouched (pkg/canary/deployment_controller.go, getSelectorLabel).
So a chart configured with `app` in its selector gets `app=<value>-primary` while
`app.kubernetes.io/name` stays as it was. Assuming the last key is suffixed produces a selector that matches
nothing at all -- a budget that exists, reports zero expected pods, and protects nothing.

When the selector contains none of those keys, flagger itself refuses the canary, so there is no correct
answer to derive and the chart stands down rather than guessing. `pdb.selectorOverride` covers that and any
cluster running flagger with a non-default `-selector-labels`.
*/}}
{{/*
The selector flagger sees: exactly what deployment.yaml puts in spec.selector.matchLabels, which is
base.selectorLabels PLUS .Values.matchLabels. Reading only the former misses a key the deployment really
carries, and flagger suffixes the first key IT finds -- so an `app` added through matchLabels is suffixed
by flagger while this chart suffixes something else, and the budget matches nothing.
*/}}
{{- define "base.pdb.targetSelector" -}}
{{- $sel := fromYaml (include "base.selectorLabels" .) -}}
{{- range $k, $v := (.Values.matchLabels | default dict) -}}
  {{- $_ := set $sel $v.name (toString $v.value) -}}
{{- end -}}
{{ toYaml $sel }}
{{- end -}}

{{- define "base.pdb.flaggerSelectorKey" -}}
{{- $sel := fromYaml (include "base.pdb.targetSelector" .) -}}
{{- /* Flagger's own default order. NOT configurable here: its -selector-labels is a controller-wide flag
       this chart does not set, so a per-release override would change only the budget and reintroduce the
       mismatch it is meant to prevent. Non-default controllers use pdb.selectorOverride. */ -}}
{{- $order := list "app" "name" "app.kubernetes.io/name" -}}
{{- range $k := $order -}}
{{- if and (not $.found) (hasKey $sel $k) -}}{{ $k }}{{- break -}}{{- end -}}
{{- end -}}
{{- end -}}

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
{{- /* An unquoted integer large enough to become a float arrives as one, and toString renders it in
       scientific notation -- so `maxUnavailable: 99999999999` was reported as
       "9.9999999999e+10 is neither a non-negative whole number", which is true of the rendering and
       useless to the reader. Format numbers as integers first so both the check and the message describe
       what was actually written. */ -}}
{{- if kindIs "float64" .value -}}
  {{- /* pdb.yaml emits the value as written, so normalising 1.5 to 2 for the range check would validate a
         number the chart never renders and hand kubernetes `maxUnavailable: 1.5`, which IntOrString cannot
         hold and the API rejects at apply time. Prove it is whole before formatting it. */ -}}
  {{- if ne (float64 .value) (floor (float64 .value)) -}}
    {{- fail (printf "base chart: pdb.%s=%v is fractional. The Kubernetes IntOrString type holds a whole number or a percentage string, so this is rejected at apply time rather than here." .field .value) -}}
  {{- end -}}
{{- end -}}
{{- $raw := ternary (printf "%.0f" (float64 .value)) (toString .value) (kindIs "float64" .value) -}}
{{- /* The range is enforced by the PATTERN, not by converting and comparing. `int` narrows, so a value like
       999999999999999999999999999% overflows to 0, sails past a `> 100` check and renders -- leaving
       kubernetes a budget it cannot evaluate, from the guard that exists to prevent exactly that. */ -}}
{{- if hasSuffix "%" $raw -}}
  {{- if not (regexMatch "^(100|[0-9]{1,2})%$" $raw) -}}
    {{- fail (printf "base chart: pdb.%s=%s is not a percentage between 0%% and 100%%. A budget cannot describe more replicas than exist." $field $raw) -}}
  {{- end -}}
{{- else -}}
  {{- if not (regexMatch "^[0-9]{1,18}$" $raw) -}}
    {{- fail (printf "base chart: pdb.%s=%s is neither a non-negative whole number nor a percentage. The Kubernetes API accepts only those two forms." $field $raw) -}}
  {{- end -}}
  {{- /* IntOrString.IntVal is an int32, so anything above 2147483647 is not representable there either. */ -}}
  {{- if gt (int64 $raw) 2147483647 -}}
    {{- fail (printf "base chart: pdb.%s=%s exceeds the int32 maximum the Kubernetes IntOrString type can hold." $field $raw) -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Whether a PodDisruptionBudget is actually rendered. The single source of truth for that decision, used by
pdb.yaml to render and by NOTES.txt to decide whether a warning about it makes any sense.
*/}}
{{- define "base.pdb.renders" -}}
{{- $pdb := .Values.pdb | default dict -}}
{{- $explicit := and (hasKey $pdb "enabled") (eq (include "base.toBool" $pdb.enabled) "true") -}}
{{- $auto := and (not (hasKey $pdb "enabled")) (include "base.pdb.mayAutoCreate" .) -}}
{{- if and (or $explicit $auto) (ge (int (include "base.pdb.floor" .)) 2) -}}
true
{{- end -}}
{{- end -}}
