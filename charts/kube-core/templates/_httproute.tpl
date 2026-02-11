{{/*
HTTPRoute template for Gateway API.

Usage:
  {{ include "common.httproute" (dict "context" $ "service" .Values.web "name" "web") }}
*/}}
{{- define "common.httproute" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- if $svc.enabled }}
{{- if $svc.httpRoute.enabled }}
{{- $fullName := include "common.fullname" . }}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ $fullName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with $svc.httpRoute.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- $_ := required "httpRoute.parentRefs is required" $svc.httpRoute.parentRefs }}
{{- $_ := required "httpRoute.rules is required" $svc.httpRoute.rules }}
spec:
  parentRefs:
    {{- toYaml $svc.httpRoute.parentRefs | nindent 4 }}
  {{- if $svc.httpRoute.hostnames }}
  hostnames:
    {{- range $svc.httpRoute.hostnames }}
    - {{ include "common.hostname" (dict "host" . "context" $ctx "service" $svc) | quote }}
    {{- end }}
  {{- end }}
  rules:
    {{- range $rule := $svc.httpRoute.rules }}
    - backendRefs:
        - name: {{ $fullName }}
          port: {{ $rule.port | default (index $svc.service.ports 0).port }}
          weight: {{ $rule.weight | default 1 }}
      {{- with $rule.matches }}
      matches:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $rule.filters }}
      filters:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    {{- end }}
{{- end }}
{{- end }}
{{- end -}}
