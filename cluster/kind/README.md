# kind Cluster

This directory contains the declarative configuration for the local Kubernetes cluster used by LGTM Platform.

## Topology

The cluster contains three nodes:

```text
control-plane
├── worker
└── worker
```

The control-plane node is reserved for Kubernetes system components. Application and observability workloads use normal Kubernetes scheduling on the two workers.

Two workers provide enough topology to explore replica placement, per-node telemetry, DaemonSets, rescheduling, and controlled worker failures without introducing a production-oriented cluster design.

## Kubernetes Version

The configuration intentionally does not declare a `kindest/node` image yet. kind therefore selects the default node image associated with the locally installed kind version.

This keeps the early project flexible, but means that identical repository revisions may use different Kubernetes versions when created with different kind releases. The node image and digest will be pinned once the observability stack introduces a concrete compatibility baseline.

## Usage

Use the repository-level Make targets rather than invoking kind directly:

```bash
make cluster
make status
make destroy
```

The default cluster name is `lgtm-platform`. It can be overridden for an individual command:

```bash
make cluster CLUSTER_NAME=lgtm-development
```

The lifecycle commands use `~/.kube/config` by default, independently from a composite ambient `KUBECONFIG`. A different file and readiness timeout can be selected explicitly:

```bash
make cluster KUBECONFIG_FILE=/path/to/config CLUSTER_WAIT_TIMEOUT=180s
```

`make cluster` waits for every node to report `Ready`. It is also idempotent: if the configured cluster already exists, it reports that there is nothing to do and exits successfully.

## Scope

This configuration does not include port mappings, ingress, a local registry, custom storage, or workload-specific node labels. These capabilities will only be added when an implemented component requires them.
