{{/*
RBAC templates for Kubernetes: Role, RoleBinding, ClusterRole, ClusterRoleBinding.

Usage:
  {{ include "common.role" (dict "context" $ "service" .Values.web "name" "web") }}
  {{ include "common.rolebinding" (dict "context" $ "service" .Values.web "name" "web") }}
  {{ include "common.clusterrole" (dict "context" $ "service" .Values.web "name" "web") }}
  {{ include "common.clusterrolebinding" (dict "context" $ "service" .Values.web "name" "web") }}
*/}}

{{/*
Role template
*/}}
{{- define "common.role" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- $rbac := $svc.rbac | default dict -}}
{{- $role := $rbac.role | default dict -}}
{{- $clusterRole := $rbac.clusterRole | default dict -}}
{{- if $svc.enabled }}
{{- if and $rbac.create (not $clusterRole.enabled) }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $role.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $role.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- $rules := default (list) $role.rules }}
{{- if eq (len $rules) 0 }}
{{ fail "RBAC rules cannot be empty when rbac.create is true" }}
{{- end }}
rules:
  {{- toYaml $rules | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
RoleBinding template
*/}}
{{- define "common.rolebinding" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- $rbac := $svc.rbac | default dict -}}
{{- $clusterRole := $rbac.clusterRole | default dict -}}
{{- $roleBinding := $rbac.roleBinding | default dict -}}
{{- if $svc.enabled }}
{{- if and $rbac.create (not $clusterRole.enabled) }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $roleBinding.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $roleBinding.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
subjects:
  - kind: ServiceAccount
    name: {{ include "common.serviceAccountName" . }}
    namespace: {{ $ctx.Release.Namespace }}
roleRef:
  kind: Role
  name: {{ include "common.fullname" . }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}
{{- end -}}

{{/*
ClusterRole template
*/}}
{{- define "common.clusterrole" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- $rbac := $svc.rbac | default dict -}}
{{- $clusterRole := $rbac.clusterRole | default dict -}}
{{- if $svc.enabled }}
{{- if and $rbac.create $clusterRole.enabled }}
{{- if not $clusterRole.rules }}
{{ fail "ClusterRole rules must be provided when rbac.clusterRole.enabled is true" }}
{{- end }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $clusterRole.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $clusterRole.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
rules:
  {{- toYaml $clusterRole.rules | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
ClusterRoleBinding template
*/}}
{{- define "common.clusterrolebinding" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- $rbac := $svc.rbac | default dict -}}
{{- $clusterRole := $rbac.clusterRole | default dict -}}
{{- $clusterRoleBinding := $rbac.clusterRoleBinding | default dict -}}
{{- if $svc.enabled }}
{{- if and $rbac.create $clusterRole.enabled $clusterRoleBinding.enabled }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $clusterRoleBinding.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $clusterRoleBinding.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
subjects:
  - kind: ServiceAccount
    name: {{ include "common.serviceAccountName" . }}
    namespace: {{ $ctx.Release.Namespace }}
roleRef:
  kind: ClusterRole
  name: {{ include "common.fullname" . }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}
{{- end -}}
