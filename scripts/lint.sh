#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly PROJECT_ROOT

shellcheck_available=true
yamllint_available=true
helm_available=true
failed_domains=0

log() {
  printf '[lint] %s\n' "$1"
}

log_domain() {
  local domain="$1"
  local message="$2"

  printf '[lint:%s] %s\n' "${domain}" "${message}"
}

check_dependencies() {
  log 'Checking required tools...'

  if ! command -v shellcheck >/dev/null 2>&1; then
    shellcheck_available=false
    log_domain 'shell' 'Required command shellcheck is not available in PATH.'
  fi

  if ! command -v yamllint >/dev/null 2>&1; then
    yamllint_available=false
    log_domain 'yaml' 'Required command yamllint is not available in PATH.'
  fi

  if ! command -v helm >/dev/null 2>&1; then
    helm_available=false
    log_domain 'helm' 'Required command helm is not available in PATH.'
  fi
}

lint_repository() {
  local status=0
  local script

  log_domain 'repository' 'Checking executable permissions...'

  for script in scripts/*.sh; do
    if [[ ! -x "${script}" ]]; then
      log_domain 'repository' "Script ${script} is not executable."
      status=1
    fi
  done

  return "${status}"
}

lint_shell() {
  local shell_files=()
  local file
  local status=0

  while IFS= read -r file; do
    shell_files[${#shell_files[@]}]="${file}"
  done < <(find . -type f -name '*.sh' -not -path './.git/*' | sort)

  if [[ ${#shell_files[@]} -eq 0 ]]; then
    log_domain 'shell' 'No shell files found.'
    return 0
  fi

  log_domain 'shell' 'Checking Bash syntax...'
  if ! bash -n "${shell_files[@]}"; then
    status=1
  fi

  if [[ "${shellcheck_available}" == false ]]; then
    return 1
  fi

  log_domain 'shell' 'Running ShellCheck...'
  if ! shellcheck "${shell_files[@]}"; then
    status=1
  fi

  return "${status}"
}

lint_yaml() {
  if [[ "${yamllint_available}" == false ]]; then
    return 1
  fi

  log_domain 'yaml' 'Running yamllint...'
  yamllint .
}

lint_helm() {
  local chart_directories=()
  local chart_directory
  local chart_file
  local helm_cache_home="${PROJECT_ROOT}/.helm/lint/cache"
  local helm_config_home="${PROJECT_ROOT}/.helm/lint/config"
  local helm_data_home="${PROJECT_ROOT}/.helm/lint/data"
  local release_name
  local status=0

  if [[ "${helm_available}" == false ]]; then
    return 1
  fi

  while IFS= read -r chart_file; do
    chart_directories[${#chart_directories[@]}]="$(dirname "${chart_file}")"
  done < <(find charts -mindepth 2 -maxdepth 2 -type f -name Chart.yaml | sort)

  if [[ ${#chart_directories[@]} -eq 0 ]]; then
    log_domain 'helm' 'No Helm charts found.'
    return 0
  fi

  mkdir -p "${helm_cache_home}" "${helm_config_home}" "${helm_data_home}"

  log_domain 'helm' 'Configuring isolated chart repositories...'
  if ! HELM_CACHE_HOME="${helm_cache_home}" HELM_CONFIG_HOME="${helm_config_home}" HELM_DATA_HOME="${helm_data_home}" \
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update; then
    return 1
  fi
  if ! HELM_CACHE_HOME="${helm_cache_home}" HELM_CONFIG_HOME="${helm_config_home}" HELM_DATA_HOME="${helm_data_home}" \
    helm repo add grafana-community https://grafana-community.github.io/helm-charts --force-update; then
    return 1
  fi
  if ! HELM_CACHE_HOME="${helm_cache_home}" HELM_CONFIG_HOME="${helm_config_home}" HELM_DATA_HOME="${helm_data_home}" \
    helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts --force-update; then
    return 1
  fi

  for chart_directory in "${chart_directories[@]}"; do
    release_name="$(basename "${chart_directory}")"

    log_domain 'helm' "Building dependencies for ${chart_directory}..."
    if ! HELM_CACHE_HOME="${helm_cache_home}" HELM_CONFIG_HOME="${helm_config_home}" HELM_DATA_HOME="${helm_data_home}" \
      helm dependency build "${chart_directory}"; then
      status=1
      continue
    fi

    log_domain 'helm' "Linting ${chart_directory}..."
    if ! HELM_CACHE_HOME="${helm_cache_home}" HELM_CONFIG_HOME="${helm_config_home}" HELM_DATA_HOME="${helm_data_home}" \
      helm lint "${chart_directory}"; then
      status=1
    fi

    log_domain 'helm' "Rendering ${chart_directory}..."
    if ! HELM_CACHE_HOME="${helm_cache_home}" HELM_CONFIG_HOME="${helm_config_home}" HELM_DATA_HOME="${helm_data_home}" \
      helm template "${release_name}" "${chart_directory}" --namespace "${release_name}" >/dev/null; then
      status=1
    fi
  done

  return "${status}"
}

run_domain() {
  local domain="$1"
  local check_function="$2"

  if "${check_function}"; then
    log_domain "${domain}" 'PASSED'
  else
    log_domain "${domain}" 'FAILED'
    failed_domains=$((failed_domains + 1))
  fi
}

main() {
  if ! cd "${PROJECT_ROOT}"; then
    printf '[lint] Unable to enter project root: %s\n' "${PROJECT_ROOT}" >&2
    exit 1
  fi

  check_dependencies
  run_domain 'repository' lint_repository
  run_domain 'shell' lint_shell
  run_domain 'yaml' lint_yaml
  run_domain 'helm' lint_helm

  if [[ "${failed_domains}" -gt 0 ]]; then
    printf '[lint] Validation failed in %d domain(s).\n' "${failed_domains}" >&2
    exit 1
  fi

  log 'All checks passed.'
}

main "$@"
