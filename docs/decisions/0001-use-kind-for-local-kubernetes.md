# ADR-0001: Use kind for Local Kubernetes

- **Status:** Accepted
- **Date:** 2026-09-22
- **Decision owners:** Project maintainers

## Context

LGTM Platform requires a local Kubernetes environment that is reproducible, disposable, compatible with Docker and WSL2, and suitable for future automated integration tests. The environment must support multiple nodes so that scheduling, per-node telemetry, DaemonSets, and controlled worker failures can be evaluated.

The initial cluster should remain easy to create and remove from a developer workstation. It should not assume managed cloud infrastructure or attempt to reproduce a highly available production cluster.

## Decision

Use kind as the local Kubernetes implementation with one control-plane node and two worker nodes.

The control-plane node remains dedicated to Kubernetes system components. Application and observability workloads use normal scheduling across the workers. The repository provides a declarative kind configuration and explicit lifecycle commands through a Makefile and small Bash scripts.

The initial configuration does not pin a `kindest/node` image. kind selects the default image associated with the locally installed kind release. The image version and digest will be pinned once the project establishes a component compatibility baseline.

## Alternatives Considered

- **Single-node kind cluster:** simpler and lighter, but unsuitable for evaluating node-level scheduling, DaemonSets, and worker failure scenarios.
- **Minikube:** capable local environment, but kind aligns more directly with disposable Docker-based clusters and future CI execution.
- **k3d:** lightweight and multi-node capable, but introduces a K3s-specific Kubernetes distribution that is not currently required.
- **Managed Kubernetes:** more representative of some production environments, but conflicts with the local-first, low-cost, and reproducible project scope.

## Consequences

### Positive

- The cluster can be created and removed with a small set of local commands.
- Multiple workers support scheduling and controlled node failure experiments.
- The Docker-based environment is suitable for WSL2, Linux, macOS, and future CI workflows.
- Cluster configuration remains versioned and reviewable.

### Negative

- All nodes share one Docker host and do not provide physical failure isolation.
- Three nodes consume more local resources than a single-node cluster.
- Kubernetes versions may differ between developers until the node image is pinned.
- A local kind cluster does not reproduce every behavior of a managed or production Kubernetes environment.

## Follow-Up

- Pin the kind node image and digest when the observability stack establishes a compatibility baseline.
- Add cluster variants only when a concrete experiment requires a different topology.
- Validate the lifecycle in CI when an integration workflow is introduced.
