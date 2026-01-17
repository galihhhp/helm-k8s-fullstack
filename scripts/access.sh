#!/usr/bin/env bash
set -euo pipefail

ACTION=${1:-open}
ENV=${2:-dev}

if [[ "$ENV" == "prod" ]]; then
    NAMESPACE="production"
else
    NAMESPACE="development"
fi

if [[ "$ACTION" == "open" ]]; then
    kubectl port-forward -n "$NAMESPACE" svc/frontend 8000:80 &
    kubectl port-forward -n "$NAMESPACE" svc/backend 3000:3000 &
elif [[ "$ACTION" == "close" ]]; then
    echo "Closing: Killing all port-forward processes..."
    pkill -f "kubectl port-forward" && echo "Done!" || echo "No port-forward processes found."
fi
