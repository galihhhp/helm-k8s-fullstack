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

Current repository structure:

```text
helm-k8s-fullstack/
  README.md
  Chart.yaml
  values-dev.yaml          # Development environment configuration

  templates/
    _helpers.tpl           # Template helpers
    configmap.yaml         # ConfigMap for application configuration
    deployment.yaml        # Deployment manifest
    namespace.yaml         # Namespace definition
    service.yaml           # Service manifest

  charts/                  # Subcharts directory (currently empty)

  scripts/
    cleanup.sh             # Cleanup script
    setup.sh               # Setup script
```

**Key directories:**

- **`values-dev.yaml`**: Development environment configuration
- **`templates/`**: Helm template files that generate Kubernetes manifests
  - **`deployment.yaml`**: Kubernetes Deployment manifest
  - **`service.yaml`**: Kubernetes Service manifest
  - **`configmap.yaml`**: ConfigMap for application configuration
  - **`namespace.yaml`**: Namespace definition
  - **`_helpers.tpl`**: Template helper functions
- **`charts/`**: Directory for subchart dependencies (currently empty)
- **`scripts/`**: Utility scripts for setup and cleanup operations

**Important Notes:**

- **Frontend/Backend code**: Your React frontend and backend API code exist in separate repositories or are already containerized
- **Container images**: Images are built separately and pushed to a container registry, then referenced in `values-dev.yaml` via `image.repository` and `image.tag`
- **`charts/` directory**: Reserved for Helm subchart dependencies (like PostgreSQL from Bitnami), NOT for your application services
- **Deployment**: Application components are deployed via Kubernetes manifests defined in `templates/`, pulling their respective container images

## Prerequisites

- Kubernetes cluster (v1.19+)
- Helm 3.x installed
- kubectl configured to access your cluster

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
  --set frontend.image.name=my-registry/frontend \
  --set frontend.image.tag=v1.0.0
```

### Using Custom Values File

```bash
helm install my-app . \
  --namespace production \
  --create-namespace \
  -f my-custom-values.yaml
```

## Configuration

The chart uses a component-based configuration structure. Each component (frontend, backend) can be configured independently in `values-dev.yaml`.

Key configuration parameters for each component:

| Parameter | Description | Example |
|-----------|-------------|---------|
| `component.enabled` | Enable/disable component | `true` |
| `component.replicaCount` | Number of replicas | `2` |
| `component.name` | Component name | `"frontend"` |
| `component.image.name` | Container image repository | `"galihhhp/react-frontend"` |
| `component.image.tag` | Container image tag | `"2.0.0"` |
| `component.image.containerPort` | Container port | `80` |
| `component.service.type` | Kubernetes service type | `ClusterIP` |
| `component.service.port` | Service port | `80` |
| `component.service.targetPort` | Target port | `80` |
| `component.env` | Environment variables | Key-value pairs |
| `namespace` | Kubernetes namespace | `"development"` |

## Components

### Frontend (React)

The React frontend is deployed as a containerized application. Configure the frontend image in `values-dev.yaml`:

```yaml
frontend:
  enabled: true
  name: "frontend"
  image:
    name: "my-registry/react-frontend"
    tag: "latest"
    containerPort: 80
```

### Task Services (Backend)

The task services backend API handles business logic and communicates with PostgreSQL. Ensure the backend service is configured with proper database connection strings via environment variables or secrets.

### PostgreSQL

PostgreSQL database should be deployed separately or as a dependency. You may need to:

1. Add PostgreSQL as a subchart dependency
2. Configure database connection in task services
3. Set up persistent volumes for data storage

## Deployment Steps

1. **Review and customize values-dev.yaml** according to your environment

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

5. **Access the application using port-forward:**
   ```bash
   kubectl port-forward svc/frontend 8080:80 -n production
   kubectl port-forward svc/backend 8081:3000 -n production
   ```
   
   Then access:
   - Frontend: `http://localhost:8080`
   - Backend API: `http://localhost:8081`

## Upgrading

```bash
helm upgrade my-app . --namespace production -f values-dev.yaml
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

Configure environment variables for your services through `values-dev.yaml`:

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

Reference secrets in your deployment via `values-dev.yaml` or directly in templates.

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

Customize these in `values-dev.yaml` based on your application's health check endpoints.

## Scaling

### Manual Scaling

```bash
kubectl scale deployment frontend --replicas=5 -n production
kubectl scale deployment backend --replicas=3 -n production
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
kubectl describe svc frontend -n production
kubectl describe svc backend -n production
```

### Common Issues

1. **Pods not starting**: Check image pull secrets and image availability
2. **Service not accessible**: Verify service type and selector labels
3. **Port-forward not working**: Ensure the service is running and the port mapping is correct
4. **Database connection issues**: Verify PostgreSQL is running and connection strings are correct

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `helm lint` and `helm template`
5. Submit a pull request

## License

[MIT](https://opensource.org/licenses/MIT)

## Support

For issues and questions, please open an issue in the repository or contact the maintainers.
