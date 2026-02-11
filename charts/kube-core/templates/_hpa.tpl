{{/*
HorizontalPodAutoscaler template for Kubernetes.

Usage:
  {{ include "common.hpa" (dict "context" $ "service" .Values.web "name" "web") }}
*/}}
{{- define "common.hpa" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- if $svc.enabled }}
{{- if $svc.autoscaling.enabled }}
{{- if not (or $svc.autoscaling.targetCPUUtilizationPercentage $svc.autoscaling.targetMemoryUtilizationPercentage $svc.autoscaling.customMetrics $svc.autoscaling.containerMetrics) }}
{{- fail "autoscaling.enabled is true but no metrics are defined" }}
{{- end }}
{{- if lt (int $svc.autoscaling.minReplicas) 1 }}
{{- fail (printf "autoscaling.minReplicas must be positive (got: %v)" $svc.autoscaling.minReplicas) }}
{{- end }}
{{- if lt (int $svc.autoscaling.maxReplicas) (int $svc.autoscaling.minReplicas) }}
{{- fail (printf "autoscaling.maxReplicas (%d) must be >= minReplicas (%d)" (int $svc.autoscaling.maxReplicas) (int $svc.autoscaling.minReplicas)) }}
{{- end }}
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "common.fullname" . }}
  minReplicas: {{ $svc.autoscaling.minReplicas }}
  maxReplicas: {{ $svc.autoscaling.maxReplicas }}
  {{- if $svc.autoscaling.behavior }}
  behavior:
    {{- if $svc.autoscaling.behavior.scaleDown }}
    scaleDown:
      {{- if $svc.autoscaling.behavior.scaleDown.stabilizationWindowSeconds }}
      stabilizationWindowSeconds: {{ $svc.autoscaling.behavior.scaleDown.stabilizationWindowSeconds }}
      {{- end }}
      {{- if $svc.autoscaling.behavior.scaleDown.policies }}
      policies:
      {{- toYaml $svc.autoscaling.behavior.scaleDown.policies | nindent 6 }}
      {{- end }}
      {{- if $svc.autoscaling.behavior.scaleDown.selectPolicy }}
      selectPolicy: {{ $svc.autoscaling.behavior.scaleDown.selectPolicy }}
      {{- end }}
    {{- end }}
    {{- if $svc.autoscaling.behavior.scaleUp }}
    scaleUp:
      {{- if $svc.autoscaling.behavior.scaleUp.stabilizationWindowSeconds }}
      stabilizationWindowSeconds: {{ $svc.autoscaling.behavior.scaleUp.stabilizationWindowSeconds }}
      {{- end }}
      {{- if $svc.autoscaling.behavior.scaleUp.policies }}
      policies:
      {{- toYaml $svc.autoscaling.behavior.scaleUp.policies | nindent 6 }}
      {{- end }}
      {{- if $svc.autoscaling.behavior.scaleUp.selectPolicy }}
      selectPolicy: {{ $svc.autoscaling.behavior.scaleUp.selectPolicy }}
      {{- end }}
    {{- end }}
  {{- end }}
  metrics:
    {{- if $svc.autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ $svc.autoscaling.targetCPUUtilizationPercentage }}
    {{- end }}
    {{- if $svc.autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ $svc.autoscaling.targetMemoryUtilizationPercentage }}
    {{- end }}
    {{- if $svc.autoscaling.customMetrics }}
    {{- toYaml $svc.autoscaling.customMetrics | nindent 4 }}
    {{- end }}
    {{- if $svc.autoscaling.containerMetrics }}
    {{- toYaml $svc.autoscaling.containerMetrics | nindent 4 }}
    {{- end }}
{{- end }}
{{- end }}
{{- end -}}
