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

{{/*
Validate app.image.repository is set
*/}}
{{- define "base.validateImageRepository" -}}
{{- if not .Values.app.image.repository }}
{{- fail "app.image.repository is required and cannot be empty" }}
{{- end }}
{{- end }}

{{/*
Validate app.ports is not empty and contains required fields
*/}}
{{- define "base.validateAppPorts" -}}
{{- if not .Values.app.ports }}
{{- fail "app.ports is required and cannot be empty" }}
{{- end }}
{{- range $index, $port := .Values.app.ports }}
{{- if not $port.name }}
{{- fail (printf "app.ports[%d].name is required" $index) }}
{{- end }}
{{- if not $port.containerPort }}
{{- fail (printf "app.ports[%d].containerPort is required" $index) }}
{{- end }}
{{- if not $port.protocol }}
{{- fail (printf "app.ports[%d].protocol is required" $index) }}
{{- end }}
{{- if not (has $port.protocol (list "TCP" "UDP" "SCTP")) }}
{{- fail (printf "app.ports[%d].protocol must be TCP, UDP, or SCTP (got: %s)" $index $port.protocol) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Validate service configuration
*/}}
{{- define "base.validateService" -}}
{{- if not .Values.service.type }}
{{- fail "service.type is required" }}
{{- end }}
{{- if not (has .Values.service.type (list "ClusterIP" "NodePort" "LoadBalancer" "ExternalName")) }}
{{- fail (printf "service.type must be ClusterIP, NodePort, LoadBalancer, or ExternalName (got: %s)" .Values.service.type) }}
{{- end }}
{{- if not .Values.service.ports }}
{{- fail "service.ports is required and cannot be empty" }}
{{- end }}
{{- range $index, $port := .Values.service.ports }}
{{- if not $port.name }}
{{- fail (printf "service.ports[%d].name is required" $index) }}
{{- end }}
{{- if not $port.port }}
{{- fail (printf "service.ports[%d].port is required" $index) }}
{{- end }}
{{- if not $port.targetPort }}
{{- fail (printf "service.ports[%d].targetPort is required" $index) }}
{{- end }}
{{- if not $port.protocol }}
{{- fail (printf "service.ports[%d].protocol is required" $index) }}
{{- end }}
{{- if not (has $port.protocol (list "TCP" "UDP" "SCTP")) }}
{{- fail (printf "service.ports[%d].protocol must be TCP, UDP, or SCTP (got: %s)" $index $port.protocol) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Validate ingress configuration when enabled
*/}}
{{- define "base.validateIngress" -}}
{{- if .Values.ingress.enabled }}
{{- if not .Values.ingress.hosts }}
{{- fail "ingress.hosts is required when ingress.enabled is true" }}
{{- end }}
{{- range $hostIndex, $host := .Values.ingress.hosts }}
{{- if not $host.host }}
{{- fail (printf "ingress.hosts[%d].host is required" $hostIndex) }}
{{- end }}
{{- if not $host.paths }}
{{- fail (printf "ingress.hosts[%d].paths is required and cannot be empty" $hostIndex) }}
{{- end }}
{{- range $pathIndex, $path := $host.paths }}
{{- if not $path.path }}
{{- fail (printf "ingress.hosts[%d].paths[%d].path is required" $hostIndex $pathIndex) }}
{{- end }}
{{- if not $path.pathType }}
{{- fail (printf "ingress.hosts[%d].paths[%d].pathType is required" $hostIndex $pathIndex) }}
{{- end }}
{{- if not (has $path.pathType (list "Exact" "Prefix" "ImplementationSpecific")) }}
{{- fail (printf "ingress.hosts[%d].paths[%d].pathType must be Exact, Prefix, or ImplementationSpecific (got: %s)" $hostIndex $pathIndex $path.pathType) }}
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.ingress.tls }}
{{- range $tlsIndex, $tls := .Values.ingress.tls }}
{{- if not $tls.secretName }}
{{- fail (printf "ingress.tls[%d].secretName is required" $tlsIndex) }}
{{- end }}
{{- if not $tls.hosts }}
{{- fail (printf "ingress.tls[%d].hosts is required and cannot be empty" $tlsIndex) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Validate HTTPRoute configuration when enabled
*/}}
{{- define "base.validateHTTPRoute" -}}
{{- if .Values.httpRoute.enabled }}
{{- if not .Values.httpRoute.parentRefs }}
{{- fail "httpRoute.parentRefs is required when httpRoute.enabled is true" }}
{{- end }}
{{- range $index, $parentRef := .Values.httpRoute.parentRefs }}
{{- if not $parentRef.name }}
{{- fail (printf "httpRoute.parentRefs[%d].name is required" $index) }}
{{- end }}
{{- end }}
{{- if not .Values.httpRoute.rules }}
{{- fail "httpRoute.rules is required and cannot be empty when httpRoute.enabled is true" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Validate ServiceMonitor configuration when enabled
*/}}
{{- define "base.validateServiceMonitor" -}}
{{- if .Values.serviceMonitor.enabled }}
{{- if not .Values.serviceMonitor.endpoints }}
{{- fail "serviceMonitor.endpoints is required when serviceMonitor.enabled is true" }}
{{- end }}
{{- range $index, $endpoint := .Values.serviceMonitor.endpoints }}
{{- if not $endpoint.port }}
{{- fail (printf "serviceMonitor.endpoints[%d].port is required" $index) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Validate RBAC role rules when enabled
*/}}
{{- define "base.validateRBAC" -}}
{{- if and .Values.rbac.create (not .Values.rbac.clusterRole.enabled) }}
{{- if not .Values.rbac.role.rules }}
{{- fail "rbac.role.rules is required when rbac.create is true and rbac.clusterRole.enabled is false" }}
{{- end }}
{{- end }}
{{- if and .Values.rbac.create .Values.rbac.clusterRole.enabled }}
{{- if not .Values.rbac.clusterRole.rules }}
{{- fail "rbac.clusterRole.rules is required when rbac.create is true and rbac.clusterRole.enabled is true" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Validate PersistentVolumes configuration
*/}}
{{- define "base.validatePersistentVolumes" -}}
{{- range $index, $pv := .Values.persistentVolumes }}
{{- if not $pv.name }}
{{- fail (printf "persistentVolumes[%d].name is required" $index) }}
{{- end }}
{{- if not $pv.mountPath }}
{{- fail (printf "persistentVolumes[%d].mountPath is required" $index) }}
{{- end }}
{{- if not $pv.storageClassName }}
{{- fail (printf "persistentVolumes[%d].storageClassName is required" $index) }}
{{- end }}
{{- if not $pv.accessModes }}
{{- fail (printf "persistentVolumes[%d].accessModes is required" $index) }}
{{- end }}
{{- if not $pv.storage }}
{{- fail (printf "persistentVolumes[%d].storage is required" $index) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Validate PrometheusRule configuration when enabled
*/}}
{{- define "base.validatePrometheusRule" -}}
{{- if .Values.prometheusRule.enabled }}
{{- if not .Values.prometheusRule.rules }}
{{- fail "prometheusRule.rules is required when prometheusRule.enabled is true" }}
{{- end }}
{{- range $ruleIndex, $rule := .Values.prometheusRule.rules }}
{{- if not $rule.name }}
{{- fail (printf "prometheusRule.rules[%d].name is required" $ruleIndex) }}
{{- end }}
{{- if not $rule.groups }}
{{- fail (printf "prometheusRule.rules[%d].groups is required" $ruleIndex) }}
{{- end }}
{{- range $groupIndex, $group := $rule.groups }}
{{- if not $group.name }}
{{- fail (printf "prometheusRule.rules[%d].groups[%d].name is required" $ruleIndex $groupIndex) }}
{{- end }}
{{- if not $group.rules }}
{{- fail (printf "prometheusRule.rules[%d].groups[%d].rules is required" $ruleIndex $groupIndex) }}
{{- end }}
{{- range $rIndex, $r := $group.rules }}
{{- if not $r.expr }}
{{- fail (printf "prometheusRule.rules[%d].groups[%d].rules[%d].expr is required" $ruleIndex $groupIndex $rIndex) }}
{{- end }}
{{- if and (not $r.alert) (not $r.record) }}
{{- fail (printf "prometheusRule.rules[%d].groups[%d].rules[%d] must have either 'alert' or 'record' defined" $ruleIndex $groupIndex $rIndex) }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Validate replica count
*/}}
{{- define "base.validateReplicaCount" -}}
{{- if not .Values.autoscaling.enabled }}
{{- if lt (int .Values.replicaCount) 0 }}
{{- fail (printf "replicaCount must be a non-negative integer (got: %v)" .Values.replicaCount) }}
{{- end }}
{{- end }}
{{- end }}
