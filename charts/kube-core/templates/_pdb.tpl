{{/*
PodDisruptionBudget template for Kubernetes.

Usage:
  {{ include "common.pdb" (dict "context" $ "service" .Values.web "name" "web") }}
*/}}
{{- define "common.pdb" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- if $svc.enabled }}
{{- if $svc.podDisruptionBudget.enabled }}
{{- if not (or $svc.podDisruptionBudget.minAvailable $svc.podDisruptionBudget.maxUnavailable) }}
  {{- fail "PodDisruptionBudget requires minAvailable or maxUnavailable" }}
{{- end }}
{{- if and $svc.podDisruptionBudget.minAvailable $svc.podDisruptionBudget.maxUnavailable }}
  {{- fail "PodDisruptionBudget cannot have both minAvailable and maxUnavailable" }}
{{- end }}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $svc.podDisruptionBudget.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $svc.podDisruptionBudget.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if $svc.podDisruptionBudget.minAvailable }}
  minAvailable: {{ $svc.podDisruptionBudget.minAvailable }}
  {{- else if $svc.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ $svc.podDisruptionBudget.maxUnavailable }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
{{- end }}
{{- end }}
{{- end -}}
