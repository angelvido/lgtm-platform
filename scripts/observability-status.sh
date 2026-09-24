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
  printf 'Error: Kubernetes context %s is not reachable. Create the cluster with make cluster.\n' "${KUBE_CONTEXT}" >&2
  exit 1
fi

if ! helm status "${OBSERVABILITY_RELEASE}" --kube-context "${KUBE_CONTEXT}" --namespace "${OBSERVABILITY_NAMESPACE}" >/dev/null 2>&1; then
  printf 'Error: observability release %s is not installed in namespace %s.\n' "${OBSERVABILITY_RELEASE}" "${OBSERVABILITY_NAMESPACE}" >&2
  exit 1
fi

helm status "${OBSERVABILITY_RELEASE}" --kube-context "${KUBE_CONTEXT}" --namespace "${OBSERVABILITY_NAMESPACE}"
printf '\nPods:\n'
kubectl get pods --context "${KUBE_CONTEXT}" --namespace "${OBSERVABILITY_NAMESPACE}" -o wide
printf '\nServices:\n'
kubectl get services --context "${KUBE_CONTEXT}" --namespace "${OBSERVABILITY_NAMESPACE}"
