# Experiments

This directory will contain executable definitions for reproducible observability experiments.

Planned experiment categories include:

- Baseline behavior and progressive traffic increases.
- Stress and resource saturation.
- Application errors and artificial latency.
- Pod or service unavailability.
- PostgreSQL and Redis degradation.
- Network-related failures.
- Trace sampling strategies.
- OpenTelemetry Collector architecture comparisons.

Chaos engineering tooling will not be introduced until the baseline platform, workloads, and measurement process are stable.

Each experiment should be stored under a stable identifier:

```text
experiments/
└── <experiment-id>/
    ├── README.md
    ├── workload/
    ├── scripts/
    └── configuration/
```

The exact contents should emerge from real experiments rather than from a premature shared framework. Depending on the scenario, an experiment definition may include:

- Load profiles, such as k6 scripts and test data.
- Preparation, execution, collection, and cleanup scripts.
- Fault or degradation configuration.
- Queries used to collect supporting system information.
- Experiment-specific configuration and validation instructions.

Each experiment should have a corresponding description based on the template under `docs/experiments/`. Executable workload and fault definitions should live here; generated evidence should live under the matching experiment identifier in `results/`.

An execution of an experiment is called an **experiment run**. Each run should capture telemetry and supporting system information over one continuous **capture window**, beginning before the condition under study and ending after its effects or recovery have been observed. Important moments within that window should be recorded as timestamped **timeline events**, rather than splitting the data into separate before, during, and after directories.

No experiments have been implemented yet.
