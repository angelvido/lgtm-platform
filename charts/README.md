# Charts

This directory contains the Helm charts maintained by the project.

Two primary deployment units are planned:

- `observability` for the shared observability platform.
- `demo-platform` for experimental applications and their service-specific monitoring resources.

The `observability` chart foundation is now present. The `demo-platform` chart will be introduced when the first application workload exists.

They should remain independently installable. The observability platform must not require the demo platform, and the demo platform should only integrate with observability through configurable, standard interfaces.

## Planned Structure

```text
charts/
├── observability/
│   ├── Chart.yaml
│   ├── Chart.lock
│   ├── values.yaml
│   ├── values.schema.json
│   ├── charts/
│   └── templates/
└── demo-platform/
    ├── Chart.yaml
    ├── values.yaml
    ├── values.schema.json
    └── templates/
        ├── workloads/
        ├── dependencies/
        └── monitoring/
```

This tree is directional. Directories will only be created when they contain real chart resources.

## Observability Chart

The observability chart should prefer pinned upstream chart dependencies over copied third-party manifests. Project-owned templates should focus on integration, configuration, resource limits, provisioning, and stable interfaces between components.

Source configuration and versioned platform assets belong under `observability/`; this chart is responsible for packaging and deploying them.

## Demo Platform Chart

The demo platform chart should own its workloads, PostgreSQL and Redis dependencies, and the Kubernetes resources required to expose application-owned observability assets. These may include `ServiceMonitor`, `PrometheusRule`, dashboard, alerting, and instrumentation resources where the target environment supports them.

The canonical source for service-specific dashboards, alerts, and recording rules belongs with each service under `apps/<service>/observability/`. The chart should package those assets rather than becoming their owner.

## Integration Boundary

The intended dependency direction is:

```text
demo-platform -- optional integration --> observability
observability -- no dependency ---------> demo-platform
```

Integration should rely on standard or configurable interfaces such as OTLP endpoints, Prometheus-compatible metrics endpoints, Kubernetes monitoring custom resources, stable Grafana datasource UIDs, and resource labels. The generic observability chart must not contain service names, application dashboards, business metrics, or alert thresholds specific to the demo platform.

The observability dependencies are being integrated incrementally and are not yet considered a complete deployable platform.
