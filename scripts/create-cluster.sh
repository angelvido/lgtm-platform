#!/usr/bin/env bash

set -euo pipefail

readonly CLUSTER_NAME="${CLUSTER_NAME:-lgtm-platform}"
readonly KUBECONFIG_FILE="${KUBECONFIG_FILE:-${HOME}/.kube/config}"
readonly CLUSTER_WAIT_TIMEOUT="${CLUSTER_WAIT_TIMEOUT:-120s}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly PROJECT_ROOT
readonly CLUSTER_CONFIG="${PROJECT_ROOT}/cluster/kind/cluster.yaml"
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

if [[ ! -f "${CLUSTER_CONFIG}" ]]; then
  printf 'Error: kind configuration not found at %s.\n' "${CLUSTER_CONFIG}" >&2
  exit 1
fi

mkdir -p "$(dirname "${KUBECONFIG_FILE}")"

if cluster_exists; then
  printf 'Cluster %s already exists. Nothing to do.\n' "${CLUSTER_NAME}"
  exit 0
fi

printf 'Creating kind cluster %s...\n' "${CLUSTER_NAME}"
kind create cluster \
  --name "${CLUSTER_NAME}" \
  --config "${CLUSTER_CONFIG}" \
  --wait "${CLUSTER_WAIT_TIMEOUT}"

printf 'Waiting for all cluster nodes to become Ready...\n'
kubectl wait \
  --context "kind-${CLUSTER_NAME}" \
  --for=condition=Ready \
  nodes \
  --all \
  --timeout "${CLUSTER_WAIT_TIMEOUT}"

printf 'Cluster %s is ready.\n' "${CLUSTER_NAME}"
