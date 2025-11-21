{{/*
Expand the name of the chart.
*/}}
{{- define "base.name" -}}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if gt (len $name) 63 }}
{{- fail (printf "Chart name '%s' is longer than 63 characters" $name) }}
{{- end }}
{{- $name }}
{{- end }}

{{/*
Create a default fully qualified app name.
We fail if longer than 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "base.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- $fullname := .Values.fullnameOverride }}
{{- if gt (len $fullname) 63 }}
{{- fail (printf "Fullname override '%s' is longer than 63 characters" $fullname) }}
{{- end }}
{{- $fullname }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- $fullname := "" }}
{{- if contains $name .Release.Name }}
{{- $fullname = .Release.Name }}
{{- else }}
{{- $fullname = printf "%s-%s" .Release.Name $name }}
{{- end }}
{{- if gt (len $fullname) 63 }}
{{- fail (printf "Generated fullname '%s' is longer than 63 characters" $fullname) }}
{{- end }}
{{- $fullname }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "base.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "base.labels" -}}
helm.sh/chart: {{ include "base.chart" . }}
{{ include "base.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "base.selectorLabels" -}}
app.kubernetes.io/name: {{ include "base.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "base.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "base.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
