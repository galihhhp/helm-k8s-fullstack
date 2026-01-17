{{- define "helm-k8s-fullstack.component.service" -}}
{{- $component := .component -}}
{{- $values := .values -}}
{{- if $values.enabled }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ required (printf "%s.name is required" $component) $values.name }}
  labels:
    {{- range $key, $value := $values.labels }}
      {{ $key }}: {{ $value }}
    {{- end }}
  namespace: {{ required "namespace is required" $.Values.namespace }}
spec:
  type: {{ required (printf "%s.service.type is required" $component) $values.service.type }}
  ports:
    - port: {{ required (printf "%s.service.port is required" $component) $values.service.port }}
      targetPort: {{ required (printf "%s.service.targetPort is required" $component) $values.service.targetPort }}
      protocol: TCP
      name: http
      {{- if and (eq $values.service.type "NodePort") $values.service.nodePort }}
      nodePort: {{ $values.service.nodePort }}
      {{- end }}
  selector:
    app: {{ $values.name }}
    tier: {{ index $values.labels "tier" }}
{{- end }}
{{- end }}
