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

The OpenTelemetry pipeline and telemetry backends are configured:

- Agent Collectors run as a DaemonSet and receive OTLP gRPC and HTTP traffic.
- Agent traffic is routed to a stable `otel-gateway` service.
- The Gateway runs as a single Deployment and receives all three telemetry signals.
- Kubernetes resource attributes are added by the Agent preset.
- Memory limiting, batching, retry, and sending queues protect the initial pipeline.
- Prometheus accepts metrics through its native OTLP HTTP receiver.
- Loki runs in monolithic mode and accepts logs through its native OTLP HTTP endpoint.
- Tempo runs in monolithic mode and accepts traces through OTLP gRPC.
- Prometheus, Loki, and Tempo use ephemeral storage with conservative local resources.
- Grafana provisions Prometheus, Loki, and Tempo datasources with stable UIDs.

Dashboards, alerts, and cross-signal correlations remain outside the current integration scope.

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

## Deployment

Use the repository command interface to create or update the release:

```bash
make observability
make observability-status
```

Access Grafana locally:

```bash
make port-forward
```

Generate a five-minute synthetic OTLP dataset for manual Grafana exploration:

```bash
make otel-traffic
```

The generated service name is `otel-demo-traffic`. Start with `{__name__=~"demo_.*"}` in Prometheus, `{service_name="otel-demo-traffic"}` in Loki, and `{ resource.service.name = "otel-demo-traffic" }` in Tempo.

The default Grafana user is `admin`. Retrieve the configured password from the `grafana-admin-credentials` Secret as documented in the root README.
Grafana credentials are provided through the existing `grafana-admin-credentials` Kubernetes Secret. The chart does not render or own credential values.

Remove the release and its dedicated namespace with:

```bash
make destroy-observability
```
