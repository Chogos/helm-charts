{{/*
ConfigMap template for Kubernetes.

Usage:
  {{ include "common.configmap" (dict "context" $ "service" .Values.web "name" "web") }}
*/}}
{{- define "common.configmap" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- if $svc.enabled }}
{{- if $svc.configmap.enabled }}
{{- if not (or $svc.configmap.data $svc.configmap.binaryData) }}
  {{- fail "ConfigMap is enabled but neither data nor binaryData is set" }}
{{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $svc.configmap.name | default (include "common.fullname" .) }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $svc.configmap.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $svc.configmap.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
data:
  {{- with $svc.configmap.data }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- if $svc.configmap.binaryData }}
binaryData:
  {{- toYaml $svc.configmap.binaryData | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
