#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

ENV=${1:-dev}

if [[ "$ENV" == "prod" ]]; then
    VALUES_FILE="$PROJECT_DIR/values-prod.yaml"
    NAMESPACE="production"
else
    VALUES_FILE="$PROJECT_DIR/values-dev.yaml"
    NAMESPACE="development"
fi

if [[ ! -f "$VALUES_FILE" ]]; then
    echo "Error: Values file not found: $VALUES_FILE"
    exit 1
fi

if [[ -z "${DB_PASSWORD:-}" ]]; then
    read -sp "Enter PostgreSQL password: " DB_PASSWORD
    echo
fi

if [[ -z "$DB_PASSWORD" ]]; then
    echo "Error: DB_PASSWORD is required"
    exit 1
fi

echo "Updating Helm dependencies..."
helm dependency update "$PROJECT_DIR"

echo "Installing/upgrading Helm release using $VALUES_FILE..."
helm upgrade --install fullstack-app "$PROJECT_DIR" \
    --namespace "$NAMESPACE" \
    --create-namespace \
    -f "$VALUES_FILE" \
    --set-string postgresql.auth.postgresPassword="$DB_PASSWORD" \
    --set-string postgresql.auth.password="$DB_PASSWORD"

sleep 15
echo "Getting all resources in namespace $NAMESPACE..."
kubectl get all -n "$NAMESPACE"

echo "Getting pods in namespace $NAMESPACE..."
kubectl get pods -n "$NAMESPACE"

echo "Getting services in namespace $NAMESPACE..."
kubectl get services -n "$NAMESPACE"

echo "Getting deployments in namespace $NAMESPACE..."
kubectl get deployments -n "$NAMESPACE"