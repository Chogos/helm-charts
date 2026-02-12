{{/*
================================================================================
COMMON LIBRARY CHART - Reusable Helm Templates
================================================================================

This library chart provides named templates that can be invoked from downstream
charts to create Kubernetes resources. Templates accept a "service context" dict
that contains:
  - context: The root context ($) from the calling chart
  - service: The service configuration values
  - name: (optional) Override for the service name

Usage in downstream chart:
  dependencies:
    - name: common
      version: 0.1.0
      repository: "file://../common"

  Then in templates:
    {{ include "common.deployment" (dict "context" $ "service" .Values.myService "name" "myservice") }}

================================================================================
*/}}

{{/*
--------------------------------------------------------------------------------
SERVICE CONTEXT HELPERS
--------------------------------------------------------------------------------
These helpers extract values from the service context, falling back to defaults.
All templates in this library expect a dict with:
  - context: Root context ($) with .Chart, .Release, .Values (global)
  - service: Service-specific values
  - name: Service name (optional, falls back to service.nameOverride or chart name)
--------------------------------------------------------------------------------
*/}}

{{/*
Get the service name from context.
Priority: explicit name > service.nameOverride > chart name
*/}}
{{- define "common.serviceName" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- $name := .name | default $svc.nameOverride | default $ctx.Chart.Name -}}
{{- if gt (len $name) 63 -}}
{{- fail (printf "Service name '%s' exceeds 63 characters" $name) -}}
{{- end -}}
{{- $name -}}
{{- end -}}

{{/*
Create a fully qualified name for the service.
*/}}
{{- define "common.fullname" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- $name := include "common.serviceName" . -}}
{{- if $svc.fullnameOverride -}}
{{- $fullname := $svc.fullnameOverride -}}
{{- if gt (len $fullname) 63 -}}
{{- fail (printf "Fullname override '%s' exceeds 63 characters" $fullname) -}}
{{- end -}}
{{- $fullname -}}
{{- else -}}
{{- $fullname := "" -}}
{{- if contains $name $ctx.Release.Name -}}
{{- $fullname = $ctx.Release.Name -}}
{{- else -}}
{{- $fullname = printf "%s-%s" $ctx.Release.Name $name -}}
{{- end -}}
{{- if gt (len $fullname) 63 -}}
{{- fail (printf "Generated fullname '%s' exceeds 63 characters" $fullname) -}}
{{- end -}}
{{- $fullname -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version for labels.
*/}}
{{- define "common.chart" -}}
{{- $ctx := .context -}}
{{- printf "%s-%s" $ctx.Chart.Name $ctx.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels for all resources.
*/}}
{{- define "common.labels" -}}
{{- $ctx := .context -}}
helm.sh/chart: {{ include "common.chart" . }}
{{ include "common.selectorLabels" . }}
{{- if $ctx.Chart.AppVersion }}
app.kubernetes.io/version: {{ $ctx.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $ctx.Release.Service }}
{{- end -}}

{{/*
Selector labels for matching pods to services/deployments.
*/}}
{{- define "common.selectorLabels" -}}
{{- $ctx := .context -}}
app.kubernetes.io/name: {{ include "common.serviceName" . }}
app.kubernetes.io/instance: {{ $ctx.Release.Name }}
{{- end -}}

{{/*
Service account name for the service.
*/}}
{{- define "common.serviceAccountName" -}}
{{- $svc := .service -}}
{{- if $svc.serviceAccount.create -}}
{{- default (include "common.fullname" .) $svc.serviceAccount.name -}}
{{- else -}}
{{- default "default" $svc.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
ConfigMap name for the service.
*/}}
{{- define "common.configMapName" -}}
{{- $svc := .service -}}
{{- $svc.configmap.name | default (include "common.fullname" .) -}}
{{- end -}}

{{/*
--------------------------------------------------------------------------------
BACKWARD COMPATIBILITY - Original "base.*" templates
--------------------------------------------------------------------------------
These maintain compatibility with existing charts using the old naming.
They delegate to common.* templates using root context.
--------------------------------------------------------------------------------
*/}}

{{- define "base.name" -}}
{{- include "common.serviceName" (dict "context" . "service" .Values) -}}
{{- end -}}

{{- define "base.fullname" -}}
{{- include "common.fullname" (dict "context" . "service" .Values) -}}
{{- end -}}

{{- define "base.chart" -}}
{{- include "common.chart" (dict "context" .) -}}
{{- end -}}

{{- define "base.labels" -}}
{{- include "common.labels" (dict "context" . "service" .Values) -}}
{{- end -}}

{{- define "base.selectorLabels" -}}
{{- include "common.selectorLabels" (dict "context" . "service" .Values) -}}
{{- end -}}

{{- define "base.serviceAccountName" -}}
{{- include "common.serviceAccountName" (dict "context" . "service" .Values) -}}
{{- end -}}

{{- define "base.configMapName" -}}
{{- include "common.configMapName" (dict "context" . "service" .Values) -}}
{{- end -}}

{{/*
--------------------------------------------------------------------------------
ALL-IN-ONE CONVENIENCE TEMPLATE
--------------------------------------------------------------------------------
Renders every enabled resource for a service in one call:
  {{ include "common.all" (dict "context" $ "service" .Values.web "name" "web") }}
--------------------------------------------------------------------------------
*/}}
{{- define "common.all" -}}
{{ include "common.serviceaccount" . }}
{{ include "common.configmap" . }}
{{ include "common.role" . }}
{{ include "common.rolebinding" . }}
{{ include "common.clusterrole" . }}
{{ include "common.clusterrolebinding" . }}
{{ include "common.service" . }}
{{ include "common.deployment" . }}
{{ include "common.hpa" . }}
{{ include "common.pdb" . }}
{{ include "common.pvc" . }}
{{ include "common.ingress" . }}
{{ include "common.httproute" . }}
{{ include "common.servicemonitor" . }}
{{ include "common.prometheusrule" . }}
{{- end -}}
