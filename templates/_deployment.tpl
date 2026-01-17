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
      serviceAccountName: {{ default $values.name $values.serviceAccountName }}
      containers:
      - name: {{ required (printf "%s.name is required" $component) $values.name }}
        image: {{ required (printf "%s.image.name is required" $component) $values.image.name }}:{{ required (printf "%s.image.tag is required" $component) $values.image.tag }}
        imagePullPolicy: {{ $values.image.pullPolicy | default "IfNotPresent" }}
        ports:
          - containerPort: {{ required (printf "%s.image.containerPort is required" $component) $values.image.containerPort }}
            name: http
        envFrom:
          - configMapRef:
              name: {{ required (printf "%s.name is required" $component) $values.name }}-config
        {{- if $values.secrets }}
        env:
          {{- range $values.secrets }}
          - name: {{ .name }}
            valueFrom:
              secretKeyRef:
                name: {{ .secretName }}
                key: {{ .key }}
          {{- end }}
        {{- end }}
        {{- if $values.healthCheck }}
        {{- if $values.healthCheck.enabled }}
        {{- if $values.healthCheck.startupProbe }}
        startupProbe:
          httpGet:
            path: {{ $values.healthCheck.startupProbe.path | default "/" }}
            port: http
          initialDelaySeconds: {{ $values.healthCheck.startupProbe.initialDelaySeconds | default 5 }}
          periodSeconds: {{ $values.healthCheck.startupProbe.periodSeconds | default 5 }}
          timeoutSeconds: {{ $values.healthCheck.startupProbe.timeoutSeconds | default 3 }}
          failureThreshold: {{ $values.healthCheck.startupProbe.failureThreshold | default 30 }}
        {{- end }}
        livenessProbe:
          httpGet:
            path: {{ $values.healthCheck.livenessProbe.path | default "/" }}
            port: http
          initialDelaySeconds: {{ $values.healthCheck.livenessProbe.initialDelaySeconds | default 30 }}
          periodSeconds: {{ $values.healthCheck.livenessProbe.periodSeconds | default 10 }}
          timeoutSeconds: {{ $values.healthCheck.livenessProbe.timeoutSeconds | default 5 }}
          failureThreshold: {{ $values.healthCheck.livenessProbe.failureThreshold | default 3 }}
        readinessProbe:
          httpGet:
            path: {{ $values.healthCheck.readinessProbe.path | default "/" }}
            port: http
          initialDelaySeconds: {{ $values.healthCheck.readinessProbe.initialDelaySeconds | default 10 }}
          periodSeconds: {{ $values.healthCheck.readinessProbe.periodSeconds | default 5 }}
          timeoutSeconds: {{ $values.healthCheck.readinessProbe.timeoutSeconds | default 3 }}
          failureThreshold: {{ $values.healthCheck.readinessProbe.failureThreshold | default 3 }}
        {{- end }}
        {{- end }}
        {{- if $values.resources }}
        resources:
          {{- toYaml $values.resources | nindent 10 }}
        {{- end }}
{{- end }}
{{- end }}
