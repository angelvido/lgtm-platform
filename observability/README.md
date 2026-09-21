# Observability

This directory will contain project-owned observability configuration and assets that should be versioned independently from third-party Helm charts.

Planned content includes:

- OpenTelemetry Collector configuration.
- Grafana dashboards, data sources, and alerting resources.
- Prometheus recording and alerting rules.
- Loki configuration owned by the project.
- Tempo configuration owned by the project.

## Planned Structure

```text
observability/
├── otel/
│   └── collector/
├── grafana/
│   ├── datasources/
│   ├── dashboards/
│   │   ├── platform/
│   │   └── infrastructure/
│   └── alerting/
├── prometheus/
│   ├── rules/
│   └── queries/
├── loki/
└── tempo/
```

Directories will be created when their first real configuration or asset is introduced. The structure may evolve as upstream chart capabilities and provisioning mechanisms are evaluated.

## Source And Packaging Boundary

This directory contains canonical, project-owned platform configuration and versioned assets. The `charts/observability/` chart is responsible for packaging and deploying them:

```text
observability/          source configuration and assets
charts/observability/   deployment packaging and integration
```

The baseline platform is expected to use OpenTelemetry, Prometheus, Loki, Tempo, and Grafana OSS. Configuration should favor a resource-conscious local laboratory rather than a highly available production topology.

Grafana resources should be provisioned as code whenever practical. Data sources will use stable UIDs so that dashboards can reference them reproducibly.

## Application Boundary

The shared platform may include dashboards and alerts about its own components and generic Kubernetes infrastructure. It must not contain knowledge specific to the demo services, such as application names, business metrics, service-level thresholds, or application dashboards.

Application-specific dashboards, alerts, recording rules, and related operational assets belong under `apps/<service>/observability/` and are packaged by `charts/demo-platform/`. This allows the observability platform to monitor other applications and the demo platform to integrate with other compatible observability environments.

Integration between both platforms should use configurable or standard interfaces, including OTLP, Prometheus-compatible metrics endpoints, Kubernetes monitoring resources, stable Grafana datasource UIDs, and discovery labels.
