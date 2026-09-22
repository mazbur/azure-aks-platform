{{/*
Selector labels — used in matchLabels and Service selector.
Keep this set small and stable: matchLabels is immutable after first apply.
*/}}
{{- define "microservices.selectorLabels" -}}
app.kubernetes.io/name: {{ .Values.deployment.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels — selector labels plus chart metadata.
Used in resource metadata.labels.
*/}}
{{- define "microservices.labels" -}}
{{ include "microservices.selectorLabels" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
ServiceAccount name.
Falls back to the deployment name when no explicit name is set.
*/}}
{{- define "microservices.serviceAccountName" -}}
{{- .Values.serviceAccount.name | default .Values.deployment.name }}
{{- end }}

{{/*
Container name.
Falls back to the deployment name when no explicit container name is set.
*/}}
{{- define "microservices.containerName" -}}
{{- .Values.deployment.containerName | default .Values.deployment.name }}
{{- end }}
