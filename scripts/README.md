# Scripts

This directory contains small operational scripts used by the repository-level `Makefile`.

The Make targets are the preferred public interface:

```bash
make help
make lint
make cluster
make status
make observability
make observability-status
make port-forward
make destroy-observability
make destroy
```

The scripts remain directly executable for troubleshooting and automation that does not use Make.

## Repository Validation

### `lint.sh`

Runs all repository validation domains and reports their results together:

- Repository conventions, including executable script permissions.
- Bash syntax and ShellCheck.
- YAML style and syntax through yamllint.
- Helm dependency resolution, chart linting, and template rendering.

The script is the shared implementation behind local validation and GitHub Actions. New technology-specific validation should be added as an explicit domain while `make lint` remains the stable public interface.

The current validation dependencies are:

- ShellCheck.
- yamllint.
- Helm 4.

The script reports missing tools but never installs them automatically.

Helm validation configures the chart repositories required by the project inside the ignored `.helm/lint/` directory. It does not modify the user's global Helm repository configuration.

## Observability Lifecycle

### `deploy-observability.sh`

Configures isolated Helm repository state under `.helm/runtime/`, creates the namespace and local Grafana administrator Secret, builds chart dependencies, and installs or upgrades the observability release. The command waits for workloads to become ready.

### `observability-status.sh`

Displays the Helm release status together with pods and services in the observability namespace.

### `port-forward-grafana.sh`

Forwards the Grafana service to `http://localhost:3000` by default. The process remains attached until interrupted.

### `destroy-observability.sh`

Uninstalls the observability release and deletes its dedicated namespace. Repeated execution is safe.

## Cluster Lifecycle

### `create-cluster.sh`

Validates the required tools and Docker daemon, creates the configured kind cluster when it does not exist, and waits for every node to report `Ready`.

### `cluster-status.sh`

Verifies that the cluster exists and displays cluster information, nodes, and pods across all namespaces.

### `destroy-cluster.sh`

Deletes the configured kind cluster when it exists. Repeated deletion is safe and exits successfully without changes.

## Configuration

The scripts accept configuration through environment variables. The Makefile exposes the same values as command-line overrides.

| Variable | Default | Purpose |
| --- | --- | --- |
| `CLUSTER_NAME` | `lgtm-platform` | Name used by kind and the generated kubectl context. |
| `KUBECONFIG_FILE` | `$HOME/.kube/config` | Kubeconfig file updated by kind and used by kubectl. |
| `CLUSTER_WAIT_TIMEOUT` | `120s` | Maximum readiness wait during cluster creation. |
| `OBSERVABILITY_NAMESPACE` | `observability` | Namespace used by the observability release. |
| `OBSERVABILITY_RELEASE` | `observability` | Helm release name for the platform. |
| `HELM_TIMEOUT` | `10m` | Maximum Helm wait time during deployment. |
| `GRAFANA_LOCAL_PORT` | `3000` | Local port used by Grafana port forwarding. |
| `GRAFANA_ADMIN_PASSWORD_FILE` | `.secrets/grafana-admin-password` | Local file used to create the Grafana administrator Secret. |

Example:

```bash
make cluster \
  CLUSTER_NAME=lgtm-development \
  KUBECONFIG_FILE="$HOME/.kube/config" \
  CLUSTER_WAIT_TIMEOUT=180s
```

## Conventions

- Scripts use Bash with `set -euo pipefail`.
- Required tools are validated but never installed automatically.
- Destructive operations must remain explicit.
- Operations should be idempotent when practical.
- Scripts should avoid platform-specific package managers and GNU-only utilities unless a concrete requirement justifies them.
- Project logic should remain understandable without relying on hidden shell state.
