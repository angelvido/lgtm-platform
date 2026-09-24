# Observability Chart

This chart packages the shared observability platform deployed into the `observability` namespace.

## Architecture

The target baseline topology is:

```text
application services
        |
       OTLP
        |
        v
OpenTelemetry Agent Collectors
        |
       OTLP
        |
        v
OpenTelemetry Gateway Collector
        |
   +----+----+
   |    |    |
   v    v    v
Prom  Loki Tempo
   \    |    /
       Grafana
```

The chart declares pinned upstream dependencies for:

- Prometheus Operator and Prometheus through `kube-prometheus-stack`.
- Grafana.
- Loki in monolithic mode.
- Tempo in monolithic mode.
- OpenTelemetry Collector as an Agent DaemonSet.
- OpenTelemetry Collector as a Gateway Deployment.

## Current State

The OpenTelemetry pipeline foundation is configured:

- Agent Collectors run as a DaemonSet and receive OTLP gRPC and HTTP traffic.
- Agent traffic is routed to a stable `otel-gateway` service.
- The Gateway runs as a single Deployment and receives all three telemetry signals.
- Kubernetes resource attributes are added by the Agent preset.
- Memory limiting, batching, retry, and sending queues protect the initial pipeline.

The Gateway currently uses the `debug` exporter until Prometheus, Loki, and Tempo are configured in the next integration step.

## Design Constraints

- The chart does not create or own the Kubernetes namespace.
- The baseline uses ephemeral storage.
- Cluster infrastructure scraping is not enabled initially.
- Dashboards and alerting configuration are outside the initial deployment scope.
- Application-specific observability resources do not belong in this chart.
- Upstream charts are consumed as dependencies rather than copied into the repository.

## Development Validation

Resolve dependencies and validate the chart with:

```bash
helm dependency build charts/observability
helm lint charts/observability
helm template observability charts/observability --namespace observability
```
