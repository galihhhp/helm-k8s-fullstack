#!/usr/bin/env bash
set -euo pipefail

ENV=${1:-dev}

if [[ "$ENV" == "prod" ]]; then
    NAMESPACE="production"
else
    NAMESPACE="development"
fi

RELEASE_NAME="${2:-fullstack-app}"

echo "This will uninstall '$RELEASE_NAME' from namespace '$NAMESPACE'"
read -p "Are you sure? (y/N): " confirm
[[ "$confirm" == [yY] ]] || { echo "Aborted."; exit 0; }

echo "Uninstalling Helm release..."
helm uninstall "$RELEASE_NAME" --namespace "$NAMESPACE" || echo "Release not found or already deleted"

read -p "Also delete namespace '$NAMESPACE'? (y/N): " delete_ns
if [[ "$delete_ns" == [yY] ]]; then
    kubectl delete namespace "$NAMESPACE" --ignore-not-found
    echo "Namespace deleted."
fi

echo "Cleanup complete!"
