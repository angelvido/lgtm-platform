#!/usr/bin/env bash

set -euo pipefail

readonly CLUSTER_NAME="${CLUSTER_NAME:-lgtm-platform}"
readonly KUBECONFIG_FILE="${KUBECONFIG_FILE:-${HOME}/.kube/config}"
readonly KUBE_CONTEXT="kind-${CLUSTER_NAME}"
export KUBECONFIG="${KUBECONFIG_FILE}"

require_command() {
  local command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Error: required command %s is not available in PATH.\n' "${command_name}" >&2
    exit 1
  fi
}

validate_cluster_name() {
  if [[ ! "${CLUSTER_NAME}" =~ ^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$ ]]; then
    printf 'Error: invalid cluster name %s. Use lowercase letters, numbers, dots, or hyphens.\n' "${CLUSTER_NAME}" >&2
    exit 1
  fi
}

cluster_exists() {
  kind get clusters 2>/dev/null | grep -Fqx "${CLUSTER_NAME}"
}

require_command docker
require_command kind
require_command kubectl
validate_cluster_name

if ! docker info >/dev/null 2>&1; then
  printf 'Error: Docker is installed but its daemon is not available. Start Docker and try again.\n' >&2
  exit 1
fi

if ! cluster_exists; then
  printf 'Error: cluster %s does not exist. Create it with make cluster.\n' "${CLUSTER_NAME}" >&2
  exit 1
fi

printf 'Cluster: %s\n' "${CLUSTER_NAME}"
printf 'Context: %s\n\n' "${KUBE_CONTEXT}"

kubectl cluster-info --context "${KUBE_CONTEXT}"
printf '\nNodes:\n'
kubectl get nodes --context "${KUBE_CONTEXT}" -o wide
printf '\nPods:\n'
kubectl get pods --all-namespaces --context "${KUBE_CONTEXT}"
