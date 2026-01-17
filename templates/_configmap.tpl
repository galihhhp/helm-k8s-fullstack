{{- define "helm-k8s-fullstack.component.configmap" -}}
{{- $component := .component -}}
{{- $values := .values -}}
{{- if $values.enabled }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ required (printf "%s.name is required" $component) $values.name }}-config
  namespace: {{ required "namespace is required" $.Values.namespace }}
  labels:
    {{- range $key, $value := $values.labels }}
      {{ $key }}: {{ $value }}
    {{- end }}
data:
    {{- if $values.env }}
    {{- range $key, $value := $values.env }}
      {{ $key }}: {{ printf "%v" $value | quote }}
    {{- end }}
    {{- end }}
{{- end }}
{{- end }}
