# LGTM Platform

A reproducible cloud-native observability platform for distributed services running on Kubernetes, built around OpenTelemetry, Prometheus, Loki, Tempo, and Grafana.

> [!NOTE]
> This repository is at an early design stage. It currently defines the project scope and repository organization; the platform is not yet deployable.

## Overview

LGTM Platform explores how to design, operate, and evaluate a modern open-source observability environment for distributed applications deployed on Kubernetes.

The project is intended to provide a local, reproducible laboratory where application behavior, infrastructure health, telemetry pipelines, and failure scenarios can be studied together. The initial environment targets developer workstations and local Kubernetes clusters rather than managed cloud infrastructure or production-scale deployments.

## Goals

- Provide a reproducible local Kubernetes observability environment.
- Collect and correlate metrics, logs, and distributed traces.
- Observe application services, Kubernetes infrastructure, PostgreSQL, and Redis.
- Manage deployments and observability configuration as code.
- Keep platform components separate from experimental applications.
- Support repeatable load, degradation, and failure experiments.
- Document architectural decisions and experimental methodology.
- Remain understandable and useful as a backend, SRE, observability, and platform engineering reference project.

## Non-Goals

The initial project scope does not include:

- Production-grade high availability or multi-cluster operation.
- Managed Kubernetes or cloud-provider-specific infrastructure.
- GitOps controllers, service meshes, eBPF platforms, or distributed metrics backends.
- Artificial intelligence or machine learning features.
- Complex demo applications before the platform foundation is established.
- Chaos engineering tooling before baseline deployments and experiments are reproducible.

## Planned Architecture

The project is organized around four independently understandable areas:

1. **Kubernetes infrastructure** — local cluster configuration and lifecycle.
2. **Observability platform** — shared telemetry collection, storage, visualization, and alerting.
3. **Demo applications** — distributed services and dependencies used as experimental workloads.
4. **Experiments and results** — reproducible scenarios, collected evidence, and analysis artifacts.

The planned telemetry flow is:

```text
Application services
        |
       OTLP
        |
        v
OpenTelemetry Collector
        |
   +----+----+
   |    |    |
   v    v    v
Prom  Loki Tempo
   \    |    /
    \   |   /
      Grafana
```

The first implementation will favor a resource-conscious local topology:

- A local Kubernetes cluster created with kind.
- A single Prometheus instance.
- Loki in monolithic mode.
- Tempo in monolithic mode.
- A single Grafana instance.
- A simple centralized OpenTelemetry Collector deployment.

Alternative Collector topologies and more advanced infrastructure telemetry will be evaluated only after the baseline platform is operational.

## Planned Technology Stack

| Area | Technology |
| --- | --- |
| Container orchestration | Kubernetes, kind |
| Packaging and deployment | Helm |
| Telemetry instrumentation and transport | OpenTelemetry, OTLP |
| Telemetry collection | OpenTelemetry Collector |
| Metrics | Prometheus |
| Logs | Loki |
| Traces | Tempo |
| Visualization and alerting | Grafana OSS |
| Application dependencies | PostgreSQL, Redis |
| Load generation | k6 |
| Continuous integration | GitHub Actions |

Technologies listed here describe the intended direction. Their presence in this table does not imply that they have already been integrated.

## Local Requirements

The repository command interface requires:

- GNU Make.
- Bash.

Repository validation additionally requires:

- ShellCheck.
- yamllint.
- Helm 4.

The current cluster lifecycle additionally requires:

- Docker with a running daemon.
- kind.
- kubectl.

WSL2 is the primary development environment. The lifecycle scripts are also designed to work on Linux and macOS when the same tools are available.

## Getting Started

List the currently available commands:

```bash
make help
```

Run all repository validation checks:

```bash
make lint
```

Create the local three-node Kubernetes cluster:

```bash
make cluster
```

Inspect its control plane, nodes, and system pods:

```bash
make status
```

Delete the cluster explicitly when it is no longer required:

```bash
make destroy
```

The default cluster name is `lgtm-platform`, and lifecycle commands use `~/.kube/config`. Override either value for an individual command with `CLUSTER_NAME=<name>` or `KUBECONFIG_FILE=<path>`.

## Repository Structure

```text
.
├── .github/              # GitHub Actions workflows
├── .yamllint.yml         # YAML validation rules
├── Makefile              # Public interface for common operations
├── apps/                 # Experimental applications and services
├── charts/               # Project-owned Helm charts
├── cluster/              # Local Kubernetes cluster configuration
├── docs/
│   ├── architecture/     # Architecture documentation
│   ├── decisions/        # Architecture Decision Records
│   └── experiments/      # Experimental methodology and documentation
├── experiments/          # Executable experiment definitions
├── observability/        # Project-owned observability configuration
├── results/              # Evidence produced by experiment runs
└── scripts/              # Local lifecycle and automation scripts
```

Each area currently contains a short description of its intended responsibility. Directories will gain implementation files only when their corresponding functionality is introduced.

## Development Principles

- **Reproducibility:** environments and experiments should be reconstructable from versioned configuration.
- **Configuration as code:** dashboards, data sources, alert rules, and platform configuration should avoid manual setup.
- **Clear ownership:** infrastructure, shared observability, applications, and experiments should remain separated.
- **Incremental delivery:** each iteration should introduce a small, verifiable capability.
- **Open standards:** prefer vendor-neutral protocols and established open-source components.
- **Explicit trade-offs:** significant decisions should be recorded as Architecture Decision Records.
- **Local-first development:** the baseline must run on a developer workstation using WSL2, Docker, and kind.
- **No premature complexity:** additional technologies require a concrete, documented need.

## Roadmap

The current high-level roadmap is:

1. Define the repository scope, structure, and contribution conventions. ✅
2. Add a minimal and reproducible kind cluster configuration. ✅
3. Introduce Helm chart foundations and pin upstream dependencies.
4. Deploy a resource-conscious baseline observability stack.
5. Add a small distributed demo platform with PostgreSQL and Redis.
6. Version dashboards, data sources, alert rules, and service monitoring resources.
7. Add repeatable load and failure experiments.
8. Compare telemetry and OpenTelemetry Collector design alternatives.

The roadmap is directional and may evolve through documented architectural decisions.

## Current Status

**Local cluster foundation.** A declarative three-node kind cluster and explicit lifecycle commands are available. The observability stack and demo applications have not been implemented yet.

## Contributing

Contributions and design discussions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for the current project conventions.

## Academic Context

This project also serves as the practical foundation for a Master's Thesis focused on the design and experimental evaluation of cloud-native observability architectures. The repository is intentionally structured as an independent open-source engineering project so that its tooling, documentation, and findings remain useful beyond the academic work.

## License

Copyright 2026 Ángel Vidal Domínguez.

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
