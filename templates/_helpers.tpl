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
  selector:
    app: {{ $values.name }}
    tier: {{ index $values.labels "tier" }}
{{- end }}
{{- end }}

{{- define "helm-k8s-fullstack.component.deployment" -}}
{{- $component := .component -}}
{{- $values := .values -}}
{{- if $values.enabled }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ required (printf "%s.name is required" $component) $values.name }}
  labels:
    {{- range $key, $value := $values.labels }}
      {{ $key }}: {{ $value }}
    {{- end }}
  namespace: {{ required "namespace is required" $.Values.namespace }}
spec:
  replicas: {{ $values.replicaCount | default 1 }}
  selector:
    matchLabels:
      app: {{ $values.name }}
      tier: {{ index $values.labels "tier" }}
  template:
    metadata:
      labels:
        {{- range $key, $value := $values.labels }}
          {{ $key }}: {{ $value }}
        {{- end }}
    spec:
      containers:
      - name: {{ required (printf "%s.name is required" $component) $values.name }}
        image: {{ required (printf "%s.image.name is required" $component) $values.image.name }}:{{ required (printf "%s.image.tag is required" $component) $values.image.tag }}
        ports:
          - containerPort: {{ required (printf "%s.image.containerPort is required" $component) $values.image.containerPort }}
        envFrom:
          - configMapRef:
              name: {{ required (printf "%s.name is required" $component) $values.name }}-config
{{- end }}
{{- end }}
