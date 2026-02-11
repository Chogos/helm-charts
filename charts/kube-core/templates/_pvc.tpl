{{/*
PersistentVolumeClaim template for Kubernetes.

Usage:
  {{ include "common.pvc" (dict "context" $ "service" .Values.web "name" "web") }}
*/}}
{{- define "common.pvc" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- if $svc.enabled }}
{{- range $svc.persistentVolumes }}
{{- $name := required "Persistent volume name is required" .name }}
{{- $accessModes := required "Access modes are required" .accessModes }}
{{- $storageClassName := required "Storage class name is required" .storageClassName }}
{{- $storage := required "Storage size is required" .storage }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "common.fullname" $ }}-{{ $name }}
  labels:
    {{- include "common.labels" $ | nindent 4 }}
spec:
  accessModes:
    {{- toYaml $accessModes | nindent 4 }}
  storageClassName: {{ $storageClassName | quote }}
  resources:
    requests:
      storage: {{ $storage | quote }}
  {{- if .volumeMode }}
  volumeMode: {{ .volumeMode }}
  {{- end }}
  {{- if .selector }}
  selector: {{- toYaml .selector | nindent 4 }}
  {{- end }}
  {{- if .volumeName }}
  volumeName: {{ .volumeName | quote }}
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}
