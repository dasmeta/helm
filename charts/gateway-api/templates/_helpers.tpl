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

{{/*
External backends of httpRoutes: every rules[].backendRefs[] item that sets `external`, as a JSON list.
Used by the HTTPRoute (Host rewrite), ServiceEntry, DestinationRule and ExternalName Service templates, so all
of them derive the same objects. Each item:
  route, name, port, host, endpoint, protocol (HTTP|HTTPS), rewriteHost, create, exportTo,
  resourceName: "ext-<route>", or "ext-<route>-<backend>" when one route has several external backends.
host defaults to the route's first hostname; endpoint defaults to host; exportTo defaults to the namespaces of the
route's parent Gateways, so the registration (and the HTTPS port declared as HTTP for TLS origination) does not
apply to other workloads of the mesh. A backend used by several rules or routes is registered once, by its first
use; later uses must not change its registration settings. Usage:
  {{- $externalBackends := include "gateway-api.externalBackends" . | fromJsonArray -}}
*/}}
{{- define "gateway-api.externalBackends" -}}
{{- $outer := . -}}
{{- $result := list -}}
{{- $seen := dict -}}
{{- $routes := .Values.httpRoutes | default (list) -}}
{{- range $idx, $route := (ternary $routes (list $routes) (kindIs "slice" $routes)) -}}
  {{- $routeName := default (printf "%s-httproute-%d" (include "gateway-api.fullname" $outer) $idx) $route.name -}}
  {{- $firstHost := "" -}}
  {{- with $route.hostnames -}}
    {{- $firstHost = tpl (toString (first .)) $outer -}}
  {{- end -}}
  {{- $gatewayNamespaces := list -}}
  {{- range (or $route.parentRefs ($outer.Values.defaultParentRefs | default (list))) -}}
    {{- $gatewayNamespaces = append $gatewayNamespaces (default "istio-system" .namespace) -}}
  {{- end -}}
  {{- $gatewayNamespaces = default (list "istio-system") ($gatewayNamespaces | uniq) -}}
  {{- $found := list -}}
  {{- range $ruleIdx, $rule := (default (list) $route.rules) -}}
    {{- $refs := default (list) (ternary (list $rule.backendRefs) $rule.backendRefs (kindIs "map" $rule.backendRefs)) -}}
    {{- range $ref := $refs -}}
      {{- if and (kindIs "map" $ref) (hasKey $ref "external") -}}
        {{- $ext := default (dict) $ref.external -}}
        {{- if gt (len $refs) 1 -}}
          {{- fail (printf "httpRoutes[%d].rules[%d]: a backendRef with external must be the only backendRef of its rule" $idx $ruleIdx) -}}
        {{- end -}}
        {{- $host := tpl (toString (default $firstHost $ext.host)) $outer -}}
        {{- if not $host -}}
          {{- fail (printf "httpRoutes[%d].rules[%d].backendRefs external.host is required when the route has no hostnames" $idx $ruleIdx) -}}
        {{- end -}}
        {{- $protocol := upper (default "HTTP" $ext.protocol) -}}
        {{- if not (has $protocol (list "HTTP" "HTTPS")) -}}
          {{- fail (printf "httpRoutes[%d].rules[%d].backendRefs external.protocol must be HTTP or HTTPS" $idx $ruleIdx) -}}
        {{- end -}}
        {{- $name := toString (default $outer.Release.Name $ref.name) -}}
        {{- $item := dict
          "route" $routeName
          "name" $name
          "port" (int (default 80 $ref.port))
          "host" $host
          "endpoint" (tpl (toString (default $host $ext.endpoint)) $outer)
          "protocol" $protocol
          "rewriteHost" (eq (toString (default false $ext.rewriteHost)) "true")
          "create" (eq (toString (default false $ext.create)) "true")
          "exportTo" (default $gatewayNamespaces $ext.exportTo)
        -}}
        {{- /* registration settings, rewriteHost is per rule (HTTPRoute filter) and may differ */ -}}
        {{- $settings := omit $item "route" "rewriteHost" | toJson -}}
        {{- if hasKey $seen $name -}}
          {{- if ne (index $seen $name) $settings -}}
            {{- fail (printf "httpRoutes[%d].rules[%d]: external backend %q is already registered with other settings (host/endpoint/port/protocol/create/exportTo)" $idx $ruleIdx $name) -}}
          {{- end -}}
        {{- else -}}
          {{- $_ := set $seen $name $settings -}}
          {{- $found = append $found $item -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- range $found -}}
    {{- $_ := set . "resourceName" (ternary (printf "ext-%s-%s" .route .name) (printf "ext-%s" .route) (gt (len $found) 1) | lower | trunc 63 | trimSuffix "-") -}}
    {{- $result = append $result . -}}
  {{- end -}}
{{- end -}}
{{- toJson $result -}}
{{- end }}
