# Fullstack Application Helm Chart

A Helm chart for deploying a fullstack application on Kubernetes, consisting of a React frontend, task services (backend API), and PostgreSQL database.

## Overview

This Helm chart provides a complete deployment solution for a fullstack application with the following components:

- **React Frontend**: Modern web application built with React
- **Task Services**: Backend API services for task management
- **PostgreSQL**: Relational database for data persistence

## Architecture

```
┌─────────────────┐
│   React App     │
│   (Frontend)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Task Services  │
│   (Backend API) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   PostgreSQL    │
│    (Database)   │
└─────────────────┘
```

## Repository Structure

This repository focuses on the Kubernetes/Helm deployment infrastructure for an existing fullstack application. The application components (React frontend, task services backend, and PostgreSQL database) are containerized and deployed using this Helm chart.

Recommended repository structure:

```text
helm-k8s-fullstack/
  README.md
  Chart.yaml
  values.yaml              # Default configuration (local/dev)
  values-dev.yaml          # Development environment
  values-staging.yaml      # Staging environment
  values-prod.yaml         # Production environment

  templates/
    deployment-frontend.yaml    # Frontend (React) deployment
    deployment-backend.yaml     # Backend (Task Services) deployment
    service-frontend.yaml       # Frontend service
    service-backend.yaml        # Backend service
    ingress.yaml                # Ingress for frontend/backend
    httproute.yaml              # Alternative: Gateway API HTTPRoute
    hpa-frontend.yaml           # HPA for frontend
    hpa-backend.yaml            # HPA for backend
    serviceaccount.yaml
    _helpers.tpl

  charts/                  # Optional: subcharts for dependencies (e.g., PostgreSQL)
    postgres/              # PostgreSQL subchart (if using Helm dependency)

  docs/
    architecture-diagram.png
    deployment-flow.md

  .github/
    workflows/
      helm-lint.yaml
      helm-release.yaml
```

**Key directories:**

- **`values-*.yaml`**: Environment-specific configurations for dev/staging/prod environments
- **`templates/`**: Helm template files that generate Kubernetes manifests
  - **Frontend & Backend**: Deployed via separate Deployment manifests (not in `charts/`)
  - **Images**: Pulled from container registry (Docker Hub, GCR, ECR, etc.) - images are not stored in this repo
- **`charts/`**: Optional subchart dependencies for infrastructure components (e.g., PostgreSQL, Redis) - NOT for your application code
- **`docs/`**: Architecture diagrams, deployment flows, and operational documentation
- **`.github/workflows/`**: CI/CD pipelines for linting, testing, and releasing the Helm chart

**Important Notes:**

- **Frontend/Backend code**: Your React frontend and backend API code exist in separate repositories or are already containerized
- **Container images**: Images are built separately and pushed to a container registry, then referenced in `values.yaml` via `image.repository` and `image.tag`
- **`charts/` directory**: Only for Helm subchart dependencies (like PostgreSQL from Bitnami), NOT for your application services
- **Deployment**: Frontend and backend are deployed as separate Kubernetes Deployments defined in `templates/`, each pulling their respective container images

## Prerequisites

- Kubernetes cluster (v1.19+)
- Helm 3.x installed
- kubectl configured to access your cluster
- (Optional) Ingress controller or Gateway API controller for external access

## Installation

### Quick Start

```bash
helm install my-app . --namespace production --create-namespace
```

### Custom Installation

```bash
helm install my-app . \
  --namespace production \
  --create-namespace \
  --set replicaCount=3 \
  --set image.repository=my-registry/frontend \
  --set image.tag=v1.0.0
```

### Using Custom Values File

```bash
helm install my-app . \
  --namespace production \
  --create-namespace \
  -f my-custom-values.yaml
```

## Configuration

The following table lists the configurable parameters and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Container image repository | `nginx` |
| `image.tag` | Container image tag | `""` (uses appVersion) |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `ingress.enabled` | Enable ingress | `false` |
| `httpRoute.enabled` | Enable HTTPRoute (Gateway API) | `false` |
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum replicas for HPA | `1` |
| `autoscaling.maxReplicas` | Maximum replicas for HPA | `100` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization | `80` |

## Components

### Frontend (React)

The React frontend is deployed as a containerized application. Configure the frontend image in `values.yaml`:

```yaml
image:
  repository: my-registry/react-frontend
  tag: "latest"
```

### Task Services (Backend)

The task services backend API handles business logic and communicates with PostgreSQL. Ensure the backend service is configured with proper database connection strings via environment variables or secrets.

### PostgreSQL

PostgreSQL database should be deployed separately or as a dependency. You may need to:

1. Add PostgreSQL as a subchart dependency
2. Configure database connection in task services
3. Set up persistent volumes for data storage

## Deployment Steps

1. **Review and customize values.yaml** according to your environment

2. **Deploy the chart:**
   ```bash
   helm install my-app . --namespace production --create-namespace
   ```

3. **Verify deployment:**
   ```bash
   kubectl get pods -n production
   kubectl get svc -n production
   ```

4. **Check application status:**
   ```bash
   helm status my-app -n production
   ```

5. **Access the application:**
   - If using Ingress: Access via the configured hostname
   - If using LoadBalancer: Get the external IP from service
   - If using ClusterIP: Use port-forward:
     ```bash
     kubectl port-forward svc/my-app 8080:80 -n production
     ```

## Upgrading

```bash
helm upgrade my-app . --namespace production -f values.yaml
```

## Rollback

```bash
helm rollback my-app --namespace production
```

## Uninstallation

```bash
helm uninstall my-app --namespace production
```

## Development

### Local Development Setup

1. **Install dependencies:**
   ```bash
   helm dependency update
   ```

2. **Lint the chart:**
   ```bash
   helm lint .
   ```

3. **Dry run to validate:**
   ```bash
   helm install my-app . --dry-run --debug --namespace production
   ```

4. **Template rendering test:**
   ```bash
   helm template my-app . --debug
   ```

## Environment Variables

Configure environment variables for your services through `values.yaml`:

```yaml
env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: postgres-secret
        key: connection-string
  - name: API_KEY
    valueFrom:
      secretKeyRef:
        name: api-secrets
        key: api-key
```

## Secrets Management

Store sensitive data in Kubernetes secrets:

```bash
kubectl create secret generic postgres-secret \
  --from-literal=username=admin \
  --from-literal=password=secret \
  --namespace production
```

Reference secrets in your deployment via `values.yaml` or directly in templates.

## Monitoring and Health Checks

The chart includes liveness and readiness probes:

```yaml
livenessProbe:
  httpGet:
    path: /
    port: http

readinessProbe:
  httpGet:
    path: /
    port: http
```

Customize these in `values.yaml` based on your application's health check endpoints.

## Scaling

### Manual Scaling

```bash
kubectl scale deployment my-app --replicas=5 -n production
```

### Automatic Scaling (HPA)

Enable Horizontal Pod Autoscaler in `values.yaml`:

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n production
kubectl describe pod <pod-name> -n production
kubectl logs <pod-name> -n production
```

### Check Service

```bash
kubectl get svc -n production
kubectl describe svc my-app -n production
```

### Check Ingress

```bash
kubectl get ingress -n production
kubectl describe ingress my-app -n production
```

### Common Issues

1. **Pods not starting**: Check image pull secrets and image availability
2. **Service not accessible**: Verify service type and selector labels
3. **Ingress not working**: Ensure ingress controller is installed and configured
4. **Database connection issues**: Verify PostgreSQL is running and connection strings are correct

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `helm lint` and `helm template`
5. Submit a pull request

## License

[Specify your license here]

## Support

For issues and questions, please open an issue in the repository or contact the maintainers.
