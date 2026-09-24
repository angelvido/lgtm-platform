#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly PROJECT_ROOT

shellcheck_available=true
yamllint_available=true
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

  if [[ "${failed_domains}" -gt 0 ]]; then
    printf '[lint] Validation failed in %d domain(s).\n' "${failed_domains}" >&2
    exit 1
  fi

  log 'All checks passed.'
}

main "$@"
