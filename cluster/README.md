# Cluster

This directory contains the configuration for local Kubernetes clusters used by the project.

The initial implementation is expected to target [kind](https://kind.sigs.k8s.io/) running on Docker within WSL2. Cluster definitions should remain minimal, reproducible, and suitable for a developer workstation.

Planned responsibilities include:

- Kubernetes version and node topology configuration.
- Local port mappings required to access platform services.
- Cluster creation and deletion instructions.
- Cluster-level prerequisites shared by the observability and demo deployments.

## Structure

```text
cluster/
└── kind/
    ├── README.md
    └── cluster.yaml
```

The initial implementation contains one understandable kind configuration rather than a hierarchy of profiles. See `kind/README.md` for its topology and usage. Additional cluster variants should only be introduced when a concrete experiment requires a different node topology or cluster-level configuration.

## Ownership Boundaries

This directory may define:

- kind node roles and Kubernetes version constraints.
- Docker-to-node port mappings.
- Node labels or cluster-level settings required before workloads are installed.

This directory should not contain:

- Application or observability workloads.
- Helm release values.
- Grafana, Prometheus, Loki, Tempo, or OpenTelemetry configuration.
- Lifecycle scripts, which are exposed through `scripts/` and the repository `Makefile`.

Application workloads and observability components do not belong in this directory. They will be packaged separately under `charts/`.
