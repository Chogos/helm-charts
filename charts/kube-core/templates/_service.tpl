{{/*
Service template for Kubernetes.

Usage:
  {{ include "common.service" (dict "context" $ "service" .Values.web "name" "web") }}
*/}}
{{- define "common.service" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- if $svc.enabled }}
{{- if $svc.service.enabled }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with $svc.service.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  type: {{ required "Service type is required" $svc.service.type }}
  ports:
    {{- $ports := $svc.service.ports }}
    {{- if not $ports }}
    {{- fail "At least one service port must be defined" }}
    {{- end }}
    {{- range $ports }}
    - port: {{ required "Port number is required" .port }}
      targetPort: {{ required "Target port is required" .targetPort }}
      protocol: {{ required "Protocol is required (TCP or UDP)" .protocol }}
      name: {{ required "Port name is required" .name }}
    {{- end }}
  selector:
    {{- include "common.selectorLabels" . | nindent 4 }}
{{- end }}
{{- end }}
{{- end -}}
