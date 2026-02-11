{{/*
ServiceAccount template for Kubernetes.

Usage:
  {{ include "common.serviceaccount" (dict "context" $ "service" .Values.web "name" "web") }}
*/}}
{{- define "common.serviceaccount" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- if $svc.enabled }}
{{- if $svc.serviceAccount.create }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "common.serviceAccountName" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with $svc.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
automountServiceAccountToken: {{ $svc.serviceAccount.automount }}
{{- end }}
{{- end }}
{{- end -}}
