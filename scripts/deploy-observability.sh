#!/usr/bin/env bash

set -euo pipefail

readonly CLUSTER_NAME="${CLUSTER_NAME:-lgtm-platform}"
readonly KUBECONFIG_FILE="${KUBECONFIG_FILE:-${HOME}/.kube/config}"
readonly KUBE_CONTEXT="kind-${CLUSTER_NAME}"
readonly OBSERVABILITY_NAMESPACE="${OBSERVABILITY_NAMESPACE:-observability}"
readonly OBSERVABILITY_RELEASE="${OBSERVABILITY_RELEASE:-observability}"
readonly HELM_TIMEOUT="${HELM_TIMEOUT:-10m}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly PROJECT_ROOT
readonly CHART_DIRECTORY="${PROJECT_ROOT}/charts/observability"
readonly HELM_STATE_DIRECTORY="${PROJECT_ROOT}/.helm/runtime"
readonly GRAFANA_ADMIN_USER="${GRAFANA_ADMIN_USER:-admin}"
readonly GRAFANA_ADMIN_PASSWORD_FILE="${GRAFANA_ADMIN_PASSWORD_FILE:-${PROJECT_ROOT}/.secrets/grafana-admin-password}"
readonly GRAFANA_ADMIN_SECRET_NAME="grafana-admin-credentials"
export KUBECONFIG="${KUBECONFIG_FILE}"
export HELM_CACHE_HOME="${HELM_STATE_DIRECTORY}/cache"
export HELM_CONFIG_HOME="${HELM_STATE_DIRECTORY}/config"
export HELM_DATA_HOME="${HELM_STATE_DIRECTORY}/data"

require_command() {
  local command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Error: required command %s is not available in PATH.\n' "${command_name}" >&2
    exit 1
  fi
}

configure_helm_repositories() {
  mkdir -p "${HELM_CACHE_HOME}" "${HELM_CONFIG_HOME}" "${HELM_DATA_HOME}"

  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update
  helm repo add grafana-community https://grafana-community.github.io/helm-charts --force-update
  helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts --force-update
}

create_grafana_admin_secret() {
  if [[ ! -s "${GRAFANA_ADMIN_PASSWORD_FILE}" ]]; then
    printf 'Error: Grafana password file not found or empty at %s.\n' "${GRAFANA_ADMIN_PASSWORD_FILE}" >&2
    printf 'Create it as documented in .secrets.example/README.md and try again.\n' >&2
    exit 1
  fi

  kubectl create secret generic "${GRAFANA_ADMIN_SECRET_NAME}" \
    --context "${KUBE_CONTEXT}" \
    --namespace "${OBSERVABILITY_NAMESPACE}" \
    --from-literal=admin-user="${GRAFANA_ADMIN_USER}" \
    --from-file=admin-password="${GRAFANA_ADMIN_PASSWORD_FILE}" \
    --dry-run=client \
    --output yaml | kubectl apply --context "${KUBE_CONTEXT}" --filename -
}

require_command helm
require_command kubectl

if ! kubectl cluster-info --context "${KUBE_CONTEXT}" >/dev/null 2>&1; then
  printf 'Error: Kubernetes context %s is not reachable. Create the cluster with make cluster.\n' "${KUBE_CONTEXT}" >&2
  exit 1
fi

if [[ ! -f "${CHART_DIRECTORY}/Chart.yaml" ]]; then
  printf 'Error: observability chart not found at %s.\n' "${CHART_DIRECTORY}" >&2
  exit 1
fi

printf 'Ensuring namespace %s exists...\n' "${OBSERVABILITY_NAMESPACE}"
if kubectl get namespace "${OBSERVABILITY_NAMESPACE}" --context "${KUBE_CONTEXT}" >/dev/null 2>&1; then
  printf 'Namespace %s already exists.\n' "${OBSERVABILITY_NAMESPACE}"
else
  kubectl create namespace "${OBSERVABILITY_NAMESPACE}" --context "${KUBE_CONTEXT}"
fi

printf 'Creating or updating Grafana administrator credentials...\n'
create_grafana_admin_secret

printf 'Configuring Helm repositories...\n'
configure_helm_repositories

printf 'Building observability chart dependencies...\n'
helm dependency build "${CHART_DIRECTORY}"

printf 'Installing observability release %s in namespace %s...\n' "${OBSERVABILITY_RELEASE}" "${OBSERVABILITY_NAMESPACE}"
helm upgrade --install "${OBSERVABILITY_RELEASE}" "${CHART_DIRECTORY}" \
  --kube-context "${KUBE_CONTEXT}" \
  --namespace "${OBSERVABILITY_NAMESPACE}" \
  --wait \
  --timeout "${HELM_TIMEOUT}"

printf 'Observability release %s is ready.\n' "${OBSERVABILITY_RELEASE}"
