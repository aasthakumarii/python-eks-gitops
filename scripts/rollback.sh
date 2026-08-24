#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=${NAMESPACE:-default}
DEPLOYMENT=${DEPLOYMENT:-python-eks-gitops}
REVISION=${1:-}

echo "Deployment: ${DEPLOYMENT}"
echo "Namespace:  ${NAMESPACE}"

echo
echo "Current rollout history:"
kubectl rollout history "deployment/${DEPLOYMENT}" -n "${NAMESPACE}"

echo

if [[ -n "${REVISION}" ]]; then
  echo "Rolling back to revision ${REVISION}..."
  kubectl rollout undo \
    "deployment/${DEPLOYMENT}" \
    -n "${NAMESPACE}" \
    --to-revision="${REVISION}"
else
  echo "Rolling back to previous revision..."
  kubectl rollout undo \
    "deployment/${DEPLOYMENT}" \
    -n "${NAMESPACE}"
fi

echo
echo "Waiting for rollback to complete..."

kubectl rollout status \
  "deployment/${DEPLOYMENT}" \
  -n "${NAMESPACE}" \
  --timeout=5m

echo
echo "Rollback completed."

echo
echo "Current image:"
kubectl get deployment "${DEPLOYMENT}" \
  -n "${NAMESPACE}" \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'