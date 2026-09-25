# ADR-0002: Use an OpenTelemetry Gateway Observability Architecture

- **Status:** Accepted
- **Date:** 2026-09-24
- **Decision owners:** Project maintainers

## Context

LGTM Platform needs a local observability architecture that can receive metrics, logs, and distributed traces from future application workloads while remaining small enough for a kind-based development environment.

The architecture should separate node-local telemetry collection from centralized processing and backend integration. It must also leave room for future experiments comparing Collector topologies without coupling the generic observability platform to the demo applications.

## Decision

Deploy OpenTelemetry Agent Collectors as a DaemonSet on worker nodes and an OpenTelemetry Gateway Collector as a centralized Deployment in the `observability` namespace.

Agents receive OTLP telemetry, enrich and batch it, and forward it to the Gateway. The Gateway exports metrics through OTLP HTTP to Prometheus, logs through OTLP HTTP to Loki, and traces through OTLP gRPC to Tempo. Grafana is provisioned as an independent frontend with stable datasources for the three backends.

Use pinned upstream Helm charts through a project-owned umbrella chart:

- `kube-prometheus-stack` with its bundled Grafana and initial cluster scraping disabled.
- The standalone Grafana chart.
- Loki in monolithic mode.
- Tempo in monolithic mode.
- Two aliased OpenTelemetry Collector chart dependencies for Agent and Gateway modes.

The initial deployment uses ephemeral storage and does not include dashboards, alert rules, ingress, TLS, or application-specific monitoring resources.

## Alternatives Considered

- **Single centralized Collector:** simpler, but does not establish the node-local Agent topology required for later architecture comparisons.
- **Direct application export to each backend:** reduces Collector configuration but couples applications to backend-specific protocols and endpoints.
- **Prometheus scraping a Collector exporter:** valid, but native OTLP ingestion keeps the initial application telemetry path consistent across all three signals.
- **Bundled Grafana from kube-prometheus-stack:** reduces one explicit dependency, but makes Grafana lifecycle and provisioning less independent.
- **Distributed Loki or Tempo:** closer to large-scale production deployments, but unnecessarily complex for a local laboratory.
- **Persistent storage from the first deployment:** preserves data across pod restarts, but adds storage configuration before baseline resource usage and retention needs are understood.

## Consequences

### Positive

- Applications depend on OTLP rather than backend-specific protocols.
- Backend integration and processing remain centralized in the Gateway.
- Agent and Gateway behavior can be evaluated independently.
- Grafana configuration can evolve without depending on kube-prometheus-stack internals.
- The baseline remains suitable for a resource-constrained local cluster.

### Negative

- Two Collector deployments require more configuration and resources than a single Collector.
- The Gateway is initially a single point of telemetry processing failure.
- Ephemeral storage loses telemetry when backend pods or the cluster are removed.
- Prometheus Operator is deployed before application-specific `ServiceMonitor` and `PrometheusRule` resources exist.

## Follow-Up

- Configure and validate every dependency before enabling it by default.
- Add persistence after measuring local storage and retention requirements.
- Add Kubernetes infrastructure telemetry in a dedicated iteration.
- Compare centralized and Agent-plus-Gateway Collector architectures experimentally.
