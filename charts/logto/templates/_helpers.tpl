{{- define "logto.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "logto.fullname" -}}
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

{{- define "logto.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{ include "logto.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "logto.selectorLabels" -}}
app.kubernetes.io/name: {{ include "logto.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "logto.image" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end }}

{{/* Host part of a URL, e.g. https://auth.example.com -> auth.example.com */}}
{{- define "logto.host" -}}
{{- (urlParse .).host | splitList ":" | first }}
{{- end }}

{{- define "logto.postgresql.fullname" -}}
{{- printf "%s-postgresql" (include "logto.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Secret + key that hold DB_URL */}}
{{- define "logto.db.secretName" -}}
{{- if and (not .Values.postgresql.enabled) .Values.externalDatabase.existingSecret }}
{{- .Values.externalDatabase.existingSecret }}
{{- else }}
{{- printf "%s-db" (include "logto.fullname" .) }}
{{- end }}
{{- end }}

{{- define "logto.db.secretKey" -}}
{{- if and (not .Values.postgresql.enabled) .Values.externalDatabase.existingSecret }}
{{- .Values.externalDatabase.existingSecretKey }}
{{- else -}}
uri
{{- end }}
{{- end }}

{{- define "logto.env" -}}
- name: DB_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "logto.db.secretName" . }}
      key: {{ include "logto.db.secretKey" . }}
{{- with .Values.endpoint }}
- name: ENDPOINT
  value: {{ . | quote }}
{{- end }}
{{- with .Values.adminEndpoint }}
- name: ADMIN_ENDPOINT
  value: {{ . | quote }}
{{- end }}
{{- if .Values.trustProxyHeader }}
- name: TRUST_PROXY_HEADER
  value: "1"
{{- end }}
{{- with .Values.extraEnv }}
{{ toYaml . }}
{{- end }}
{{- end }}
