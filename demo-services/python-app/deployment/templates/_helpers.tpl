{{/*
Expand the name of the chart.
*/}}
{{- define "py_log_demo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "py_log_demo.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "py_log_demo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "py_log_demo.labels" -}}
{{- if $.Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "py_log_demo.selectorLabels" $ }}
{{- range $key, $value := .Values.labels }}
{{ $key }}: {{ quote $value }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "py_log_demo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "py_log_demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/type: {{ .Values.type }}
{{- end }}

{{/*
Deployment annotations
*/}}
{{- define "py_log_demo.annotations" -}}
{{- range $key, $value := .annotations }}
{{ $key }}: {{ quote $value }}
{{- end }}
app.kubernetes.io/name: {{ include "py_log_demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/type: {{ .Values.type }}
{{- if .Values.monitoring.enabled }}
{{ include "py_log_demo.monitoring_annotations" .}}
{{- end -}}
{{- end }}

{{/*
Monitoring annotations
*/}}
{{- define "py_log_demo.monitoring_annotations" -}}
prometheus.io/scrape: true
prometheus.io/path: {{ .Values.monitoring.metrics_path | default "/metrics" | quote }}
prometheus.io/port: {{ .Values.monitoring.metrics_port_number | default "8080" | quote }}
{{- end }}


{{/*
Evaluate resources
*/}}
{{- define "py_log_demo.resources" -}}
{{- if .Values.check_recommended }}
{{- with (required "Specify resources for deployment to install chart." .Values.resources) -}}
resources:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- else }}
{{- with  .Values.resources -}}
resources:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
priority class name
*/}}
{{- define "py_log_demo.priorityClassName" -}}
{{- $pcn := .Values.priorityClassName -}}
{{- if $pcn }}
priorityClassName: {{ $pcn }}
{{- end }}
{{- end }}
