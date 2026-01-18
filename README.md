# Fullstack Application Helm Chart

A Helm chart for deploying a fullstack application on Kubernetes, consisting of a React frontend, task services (backend API), and PostgreSQL database.

## Overview

This Helm chart provides a complete deployment solution for a fullstack application with the following components:

- **React Frontend**: Modern web application built with React
- **Task Services**: Backend API services for task management
- **PostgreSQL**: Relational database (Bitnami subchart) with automatic schema initialization

## Architecture

```
┌─────────────────┐
│   React App     │
│   (Frontend)    │
│   Port: 80      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Task Services  │
│   (Backend)     │
│   Port: 3000    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   PostgreSQL    │
│   (Bitnami)     │
│   Port: 5432    │
└─────────────────┘
```

## Repository Structure

```text
helm-k8s-fullstack/
├── Chart.yaml                # Chart metadata and dependencies
├── Chart.lock                # Locked dependency versions
├── values.yaml               # Default configuration values
├── values-dev.yaml           # Development environment configuration
├── values-prod.yaml          # Production environment configuration
│
├── charts/
│   └── postgresql-18.2.0.tgz # Bitnami PostgreSQL subchart
│
├── templates/
│   ├── _helpers.tpl          # Template helpers
│   ├── _deployment.tpl       # Reusable deployment template
│   ├── _service.tpl          # Reusable service template
│   ├── _configmap.tpl        # Reusable configmap template
│   ├── configmap.yaml        # ConfigMap manifest
│   ├── deployment.yaml       # Deployment manifest
│   ├── service.yaml          # Service manifest
│   ├── namespace.yaml        # Namespace definition
│   ├── networkpolicy.yaml    # Network policies for security
│   └── serviceaccount.yaml   # Service accounts
│
└── scripts/
    ├── setup.sh              # Deploy/upgrade the application
    ├── cleanup.sh            # Uninstall the application
    └── access.sh             # Port-forward for local access
```

## Prerequisites

- Kubernetes cluster (v1.19+)
- Helm 3.x installed
- kubectl configured to access your cluster

## Quick Start

### Deploy to Development

```bash
./scripts/setup.sh dev
```

### Deploy to Production

```bash
./scripts/setup.sh prod
```

The setup script will:
1. Prompt for PostgreSQL password (or use `DB_PASSWORD` env var)
2. Update Helm dependencies
3. Install/upgrade the release
4. Display deployment status

### Access the Application

```bash
./scripts/access.sh open dev
```

This opens port-forwards:
- Frontend: `http://localhost:8000`
- Backend API: `http://localhost:3000`

To close port-forwards:

```bash
./scripts/access.sh close
```

### Cleanup

```bash
./scripts/cleanup.sh dev
```

## Configuration

### Environment Values Files

| File | Environment | Namespace | Network Policy |
|------|-------------|-----------|----------------|
| `values.yaml` | Default | `default` | Disabled |
| `values-dev.yaml` | Development | `development` | Disabled |
| `values-prod.yaml` | Production | `production` | Enabled |

### Component Configuration

Each component (frontend, backend) supports the following configuration:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `component.enabled` | Enable/disable component | `true` |
| `component.replicaCount` | Number of replicas | `2` (dev), `3` (prod) |
| `component.name` | Component name | `"frontend"` / `"backend"` |
| `component.serviceAccountName` | Service account name | Component name |
| `component.image.name` | Container image | `"galihhhp/react-frontend"` |
| `component.image.tag` | Image tag | `"2.0.0"` |
| `component.image.pullPolicy` | Pull policy | `"Always"` (dev), `"IfNotPresent"` (prod) |
| `component.image.containerPort` | Container port | `80` / `3000` |
| `component.service.type` | Service type | `ClusterIP` |
| `component.service.port` | Service port | `80` / `3000` |
| `component.env` | Environment variables | See values files |
| `component.secrets` | Secret references | Backend DB password |
| `component.healthCheck` | Health check configuration | Enabled with probes |
| `component.resources` | CPU/Memory requests and limits | See values files |

### Feature Flags

Configure feature flags via environment variables:

**Frontend:**
```yaml
env:
  API_URL: "http://localhost:3000"
  FEATURE_EDIT_TASK: "true"
  FEATURE_DELETE_TASK: "true"
  FEATURE_SHOW_TASKS: "true"
  FEATURE_SHOW_USERS: "false"
  VITE_APP_VERSION: "2.0.0"
```

**Backend:**
```yaml
env:
  NODE_ENV: "production"
  DB_HOST: "fullstack-app-postgresql"
  DB_PORT: "5432"
  DB_NAME: "postgres"
  DB_USER: "postgres"
  DB_COLUMN_ID: "id"
  DB_COLUMN_TASK: "task"
  FEATURE_EDIT_TASK: "true"
  FEATURE_DELETE_TASK: "true"
  FEATURE_REDIS_CACHE: "false"
```

### Health Checks

All components include configurable health probes:

```yaml
healthCheck:
  enabled: true
  startupProbe:
    path: "/"
    initialDelaySeconds: 5
    periodSeconds: 5
    timeoutSeconds: 3
    failureThreshold: 30
  livenessProbe:
    path: "/"
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 3
  readinessProbe:
    path: "/"
    initialDelaySeconds: 10
    periodSeconds: 5
    timeoutSeconds: 3
    failureThreshold: 3
```

### Resource Limits

**Development:**
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

**Production:**
```yaml
resources:
  requests:
    cpu: "200m"
    memory: "256Mi"
  limits:
    cpu: "1"
    memory: "1Gi"
```

## Components

### Frontend (React)

The React frontend is deployed with:
- Configurable replica count
- ClusterIP service on port 80
- Feature flags for UI features
- Health checks for reliability

### Backend (Task Services)

The backend API includes:
- Database connection to PostgreSQL
- Secret-based password management
- Feature flags for API features
- Health checks for reliability

### PostgreSQL (Bitnami Subchart)

PostgreSQL is deployed as a Bitnami subchart dependency with:
- Automatic database initialization via `init.sql`
- Persistent storage (10Gi dev, 20Gi prod)
- Configurable resources

**Database Schema (auto-created):**
```sql
CREATE TABLE IF NOT EXISTS main_table (
    id SERIAL PRIMARY KEY,
    task VARCHAR(255) NOT NULL
);
```

## Network Policies

Network policies are enabled in production (`values-prod.yaml`) to restrict traffic:

**Frontend Policy:**
- Ingress: Allow HTTP (port 80) from any namespace
- Egress: Allow only to backend (port 3000) and DNS

**Backend Policy:**
- Ingress: Allow only from frontend (port 3000)
- Egress: Allow only to PostgreSQL (port 5432) and DNS

Enable/disable via:
```yaml
networkPolicy:
  enabled: true  # or false
```

## Manual Installation

If you prefer not to use the scripts:

### Install

```bash
helm dependency update

helm upgrade --install fullstack-app . \
  --namespace development \
  --create-namespace \
  -f values-dev.yaml \
  --set-string postgresql.auth.postgresPassword="your-password" \
  --set-string postgresql.auth.password="your-password"
```

### Upgrade

```bash
helm upgrade fullstack-app . \
  --namespace development \
  -f values-dev.yaml \
  --set-string postgresql.auth.postgresPassword="your-password" \
  --set-string postgresql.auth.password="your-password"
```

### Uninstall

```bash
helm uninstall fullstack-app --namespace development
kubectl delete namespace development  # Optional
```

## Development

### Lint the Chart

```bash
helm lint .
```

### Dry Run

```bash
helm install fullstack-app . --dry-run --debug \
  -f values-dev.yaml \
  --set-string postgresql.auth.postgresPassword="test"
```

### Template Rendering

```bash
helm template fullstack-app . \
  -f values-dev.yaml \
  --set-string postgresql.auth.postgresPassword="test"
```

### Update Dependencies

```bash
helm dependency update
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n development
kubectl describe pod <pod-name> -n development
kubectl logs <pod-name> -n development
```

### Check Services

```bash
kubectl get svc -n development
kubectl describe svc frontend -n development
kubectl describe svc backend -n development
```

### Check PostgreSQL

```bash
kubectl get pods -n development -l app.kubernetes.io/name=postgresql
kubectl logs -n development -l app.kubernetes.io/name=postgresql
```

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Pods not starting | Image pull error | Check image name/tag and registry access |
| Database connection failed | Wrong credentials | Verify `DB_PASSWORD` matches PostgreSQL password |
| Service not accessible | Wrong selector | Check labels match between deployment and service |
| Port-forward not working | Service not ready | Wait for pods to be in `Running` state |
| PostgreSQL CrashLoopBackOff | Resource limits | Increase memory limits for PostgreSQL |

### View Helm Release

```bash
helm status fullstack-app -n development
helm history fullstack-app -n development
```

### Rollback

```bash
helm rollback fullstack-app 1 -n development
```

## Scaling

### Manual Scaling

```bash
kubectl scale deployment frontend --replicas=5 -n development
kubectl scale deployment backend --replicas=3 -n development
```

### Via Helm Values

Update `replicaCount` in values file and upgrade:

```bash
./scripts/setup.sh dev
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `helm lint` and `helm template`
5. Submit a pull request

## License

[MIT](https://opensource.org/licenses/MIT)

## Support

For issues and questions, please open an issue in the repository.
