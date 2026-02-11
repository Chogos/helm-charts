{{/*
Prometheus Operator templates: ServiceMonitor and PrometheusRule.

Usage:
  {{ include "common.servicemonitor" (dict "context" $ "service" .Values.web "name" "web") }}
  {{ include "common.prometheusrule" (dict "context" $ "service" .Values.web "name" "web") }}
*/}}

{{/*
ServiceMonitor template
*/}}
{{- define "common.servicemonitor" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- if $svc.enabled }}
{{- if $svc.serviceMonitor.enabled }}
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with $svc.serviceMonitor.labels }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $svc.serviceMonitor.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if $svc.serviceMonitor.jobLabel }}
  jobLabel: {{ $svc.serviceMonitor.jobLabel }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
    {{- with $svc.serviceMonitor.selector }}
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- if not $svc.serviceMonitor.endpoints }}
  {{ fail "serviceMonitor.endpoints must contain at least one endpoint" }}
  {{- end }}
  endpoints:
  {{- range $svc.serviceMonitor.endpoints }}
    - port: {{ required "endpoint.port is required" .port }}
      {{- if .interval }}
      interval: {{ .interval }}
      {{- end }}
      {{- if .scrapeTimeout }}
      scrapeTimeout: {{ .scrapeTimeout }}
      {{- end }}
      {{- if .path }}
      path: {{ .path }}
      {{- end }}
      {{- if .scheme }}
      scheme: {{ .scheme }}
      {{- end }}
      {{- if hasKey . "honorLabels" }}
      honorLabels: {{ .honorLabels }}
      {{- end }}
      {{- if hasKey . "honorTimestamps" }}
      honorTimestamps: {{ .honorTimestamps }}
      {{- end }}
      {{- if .relabelings }}
      relabelings:
        {{- toYaml .relabelings | nindent 8 }}
      {{- end }}
      {{- if .metricRelabelings }}
      metricRelabelings:
        {{- toYaml .metricRelabelings | nindent 8 }}
      {{- end }}
      {{- if .tlsConfig }}
      tlsConfig:
        {{- toYaml .tlsConfig | nindent 8 }}
      {{- end }}
      {{- if .basicAuth }}
      basicAuth:
        {{- toYaml .basicAuth | nindent 8 }}
      {{- end }}
      {{- if .authorization }}
      authorization:
        {{- toYaml .authorization | nindent 8 }}
      {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
PrometheusRule template
*/}}
{{- define "common.prometheusrule" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- if $svc.enabled }}
{{- if and $svc.prometheusRule.enabled $svc.prometheusRule.rules }}
{{- range $svc.prometheusRule.rules }}
---
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: {{ include "common.fullname" $ }}-{{ required "Rule name is required" .name }}
  labels:
    {{- include "common.labels" $ | nindent 4 }}
{{- if $svc.prometheusRule.prometheusLabel }}
    prometheus: {{ $svc.prometheusRule.prometheusLabel }}
{{- end }}
    role: alert-rules
spec:
  groups:
{{- range .groups }}
    - name: {{ required "Group name is required" .name }}
      rules:
{{- range .rules }}
{{- if not (or .alert .record) }}{{ fail "Each rule must specify either 'alert' or 'record'" }}{{ end }}
{{- if .alert }}
        - alert: {{ .alert }}
          expr: {{ required "Expression is required for alert rule" .expr }}
{{- if .for }}
          for: {{ .for }}
{{- end }}
{{- if .labels }}
          labels:
{{- range $key, $value := .labels }}
            {{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- if .annotations }}
          annotations:
{{- range $key, $value := .annotations }}
            {{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- else if .record }}
        - record: {{ .record }}
          expr: {{ required "Expression is required for recording rule" .expr }}
{{- if .labels }}
          labels:
{{- range $key, $value := .labels }}
            {{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
