#!/usr/bin/env bash

set -euo pipefail

readonly CLUSTER_NAME="${CLUSTER_NAME:-lgtm-platform}"
readonly KUBECONFIG_FILE="${KUBECONFIG_FILE:-${HOME}/.kube/config}"
readonly KUBE_CONTEXT="kind-${CLUSTER_NAME}"
readonly OBSERVABILITY_NAMESPACE="${OBSERVABILITY_NAMESPACE:-observability}"
readonly OBSERVABILITY_RELEASE="${OBSERVABILITY_RELEASE:-observability}"
export KUBECONFIG="${KUBECONFIG_FILE}"

require_command() {
  local command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Error: required command %s is not available in PATH.\n' "${command_name}" >&2
    exit 1
  fi
}

require_command helm
require_command kubectl

if ! kubectl cluster-info --context "${KUBE_CONTEXT}" >/dev/null 2>&1; then
  printf 'Cluster context %s is not reachable. Nothing to do.\n' "${KUBE_CONTEXT}"
  exit 0
fi

if helm status "${OBSERVABILITY_RELEASE}" --kube-context "${KUBE_CONTEXT}" --namespace "${OBSERVABILITY_NAMESPACE}" >/dev/null 2>&1; then
  printf 'Uninstalling observability release %s...\n' "${OBSERVABILITY_RELEASE}"
  helm uninstall "${OBSERVABILITY_RELEASE}" --kube-context "${KUBE_CONTEXT}" --namespace "${OBSERVABILITY_NAMESPACE}"
else
  printf 'Observability release %s is not installed.\n' "${OBSERVABILITY_RELEASE}"
fi

if kubectl get namespace "${OBSERVABILITY_NAMESPACE}" --context "${KUBE_CONTEXT}" >/dev/null 2>&1; then
  printf 'Deleting namespace %s...\n' "${OBSERVABILITY_NAMESPACE}"
  kubectl delete namespace "${OBSERVABILITY_NAMESPACE}" --context "${KUBE_CONTEXT}" --wait=true
else
  printf 'Namespace %s does not exist. Nothing to do.\n' "${OBSERVABILITY_NAMESPACE}"
fi
