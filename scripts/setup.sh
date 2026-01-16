SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
NAMESPACE="development"

helm upgrade --install fullstack-app $PROJECT_DIR --namespace $NAMESPACE /
--create-namespace -f $PROJECT_DIR/values-dev.yaml

kubectl get all -n $NAMESPACE