{{/*
Deployment template for Kubernetes workloads.

Usage:
  {{ include "common.deployment" (dict "context" $ "service" .Values.web "name" "web") }}
*/}}
{{- define "common.deployment" -}}
{{- $ctx := .context -}}
{{- $svc := .service -}}
{{- if $svc.enabled }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.fullname" . }}
  {{- with $svc.deploymentAnnotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with $svc.deploymentLabels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  {{- if not $svc.autoscaling.enabled }}
  replicas: {{ $svc.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
        {{- if and $svc.configmap.enabled (or $svc.configmap.data $svc.configmap.binaryData) }}
        checksum/config: {{ include "common.configmap" . | sha256sum }}
        {{- end }}
        {{- with $svc.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      labels:
        {{- include "common.labels" . | nindent 8 }}
        {{- with $svc.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with $svc.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "common.serviceAccountName" . }}
      enableServiceLinks: {{ $svc.enableServiceLinks }}
      {{- with $svc.podSecurityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $svc.initContainers }}
      initContainers:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: "main"
          {{- with $svc.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          image: "{{ required "app.image.repository is required" $svc.app.image.repository }}:{{ $svc.app.image.tag | default $ctx.Chart.AppVersion }}"
          imagePullPolicy: {{ $svc.app.image.pullPolicy | default "IfNotPresent" }}
          {{- with $svc.app.command }}
          command:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $svc.app.args }}
          args:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          ports:
            {{- range $svc.app.ports }}
            - name: {{ .name }}
              containerPort: {{ .containerPort }}
              protocol: {{ .protocol }}
            {{- end }}
          {{- with $svc.app.env }}
          env:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $svc.app.envFrom }}
          envFrom:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $svc.livenessProbe }}
          livenessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $svc.readinessProbe }}
          readinessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $svc.startupProbe }}
          startupProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $svc.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if or ($svc.volumeMounts) ($svc.persistentVolumes) (and $svc.configmap.enabled $svc.configmap.mount.enabled) }}
          volumeMounts:
            {{- if and $svc.configmap.enabled $svc.configmap.mount.enabled }}
            - name: {{ include "common.fullname" . }}-config
              mountPath: {{ required "configmap.mount.mountPath is required when configmap.mount.enabled is true" $svc.configmap.mount.mountPath }}
              {{- with $svc.configmap.mount.readOnly }}
              readOnly: {{ . }}
              {{- end }}
              {{- with $svc.configmap.mount.subPath }}
              subPath: {{ . }}
              {{- end }}
            {{- end }}
            {{- with $svc.volumeMounts }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
            {{- range $svc.persistentVolumes }}
            - name: {{ .name }}
              mountPath: {{ .mountPath }}
            {{- end }}
          {{- end }}
        {{- with $svc.sidecars }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- if or ($svc.volumes) ($svc.persistentVolumes) (and $svc.configmap.enabled $svc.configmap.mount.enabled) }}
      volumes:
        {{- if and $svc.configmap.enabled $svc.configmap.mount.enabled }}
        - name: {{ include "common.fullname" . }}-config
          configMap:
            name: {{ include "common.configMapName" . }}
            {{- with $svc.configmap.mount.items }}
            items:
            {{- toYaml . | nindent 12 }}
            {{- end }}
        {{- end }}
        {{- if $svc.volumes }}
        {{- range $svc.volumes }}
        {{- if and .configMap (not .configMap.name) ($svc.configmap.enabled) }}
        - name: {{ .name }}
          configMap:
            name: {{ include "common.configMapName" $ }}
            {{- with .configMap.defaultMode }}
            defaultMode: {{ . }}
            {{- end }}
            {{- with .configMap.items }}
            items:
            {{- toYaml . | nindent 12 }}
            {{- end }}
            {{- with .configMap.optional }}
            optional: {{ . }}
            {{- end }}
        {{- else }}
        - {{ toYaml . | nindent 10 | trim }}
        {{- end }}
        {{- end }}
        {{- end }}
        {{- range $svc.persistentVolumes }}
        - name: {{ .name }}
          persistentVolumeClaim:
            claimName: {{ include "common.fullname" $ }}-{{ .name }}
        {{- end }}
      {{- end }}
      {{- with $svc.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $svc.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $svc.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $svc.topologySpreadConstraints }}
      topologySpreadConstraints:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
{{- end -}}
