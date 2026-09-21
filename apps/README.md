# Applications

This directory will contain source code for the distributed services used as experimental workloads.

The planned baseline topology is:

```text
load generator
      |
      v
   frontend
      |
      v
    backend
     /   \
    v     v
PostgreSQL Redis
```

The first application implementation should remain intentionally small while still providing meaningful HTTP, database, cache, metrics, logs, and distributed tracing behavior. Additional backend services may be introduced later when they support a specific tracing or failure-analysis objective.

## Planned Structure

Applications will be organized by independently buildable and testable service:

```text
apps/
├── frontend/
│   ├── README.md
│   ├── src/
│   ├── tests/
│   ├── Dockerfile
│   └── observability/
│       ├── dashboards/
│       ├── alerts/
│       └── recording-rules/
└── backend/
    ├── README.md
    ├── src/
    ├── tests/
    ├── Dockerfile
    └── observability/
        ├── dashboards/
        ├── alerts/
        └── recording-rules/
```

The exact source layout within each service will follow the conventions of its chosen language and framework. Shared libraries will only be introduced when real duplication justifies them.

## Ownership Boundaries

Each service should own:

- Its source code, tests, and container image definition.
- Its telemetry instrumentation and operational documentation.
- Dashboards, alerts, recording rules, and service-level monitoring knowledge specific to that service.

Keeping application-specific observability assets with their owning service allows the demo platform to evolve independently from the generic observability platform. It also makes those assets available when the applications are deployed against another compatible observability stack.

PostgreSQL and Redis are runtime dependencies rather than applications developed in this repository, so their deployment configuration belongs under `charts/demo-platform/`. Experiment-specific k6 workloads belong under `experiments/<experiment-id>/` rather than in this directory.

Kubernetes packaging belongs under `charts/demo-platform/`. The chart may package resources sourced from each service's `observability/` directory, but it should not become the canonical location for their application-specific content.

No application services have been implemented yet.
