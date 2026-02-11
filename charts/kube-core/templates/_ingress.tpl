{{/*
Ingress template for Kubernetes.

Usage:
  {{ include "common.ingress" (dict "context" $ "service" .Values.web "name" "web") }}
*/}}
{{- define "common.ingress" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- if $svc.enabled }}
{{- if and $svc.ingress.enabled (not $svc.ingress.hosts) }}
{{ fail "Ingress is enabled but no hosts are configured" }}
{{- end }}
{{- if $svc.ingress.enabled }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with $svc.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with $svc.ingress.className }}
  ingressClassName: {{ . }}
  {{- end }}
  {{- if $svc.ingress.tls }}
  tls:
    {{- range $svc.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ include "common.hostname" (dict "host" . "context" $ctx "service" $svc) | quote }}
        {{- end }}
      secretName: {{ required "secretName is required for TLS" .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range $svc.ingress.hosts }}
    - host: {{ include "common.hostname" (dict "host" .host "context" $ctx "service" $svc) | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType | default "Prefix" }}
            backend:
              service:
                name: {{ include "common.fullname" $ }}
                port:
                  number: {{ required "A port must be specified for ingress paths" (.port | default (index $svc.service.ports 0).port) }}
          {{- end }}
    {{- end }}
{{- end }}
{{- end }}
{{- end -}}
