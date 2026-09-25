#!/usr/bin/env bash

set -euo pipefail

readonly CLUSTER_NAME="${CLUSTER_NAME:-lgtm-platform}"
readonly KUBECONFIG_FILE="${KUBECONFIG_FILE:-${HOME}/.kube/config}"
readonly KUBE_CONTEXT="kind-${CLUSTER_NAME}"
readonly OBSERVABILITY_NAMESPACE="${OBSERVABILITY_NAMESPACE:-observability}"
readonly GRAFANA_LOCAL_PORT="${GRAFANA_LOCAL_PORT:-3000}"
export KUBECONFIG="${KUBECONFIG_FILE}"

require_command() {
  local command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Error: required command %s is not available in PATH.\n' "${command_name}" >&2
    exit 1
  fi
}

require_command kubectl

if ! kubectl get service grafana --context "${KUBE_CONTEXT}" --namespace "${OBSERVABILITY_NAMESPACE}" >/dev/null 2>&1; then
  printf 'Error: Grafana service is not available. Deploy observability with make observability.\n' >&2
  exit 1
fi

printf 'Grafana will be available at http://localhost:%s\n' "${GRAFANA_LOCAL_PORT}"
printf 'Press Ctrl+C to stop port forwarding.\n'
kubectl port-forward \
  --context "${KUBE_CONTEXT}" \
  --namespace "${OBSERVABILITY_NAMESPACE}" \
  service/grafana "${GRAFANA_LOCAL_PORT}:80"
