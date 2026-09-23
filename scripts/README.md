# Scripts

This directory contains small operational scripts used by the repository-level `Makefile`.

The Make targets are the preferred public interface:

```bash
make help
make cluster
make status
make destroy
```

The scripts remain directly executable for troubleshooting and automation that does not use Make.

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
