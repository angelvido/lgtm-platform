# Results

This directory is reserved for evidence produced by repeatable experiments. Results should be organized first by experiment and then by execution, rather than grouped globally by file type.

The planned structure is:

```text
results/
└── <experiment-id>/
    ├── runs/
    │   └── <run-id>/
    │       ├── manifest.yaml
    │       ├── telemetry/
    │       │   ├── metrics/
    │       │   ├── logs/
    │       │   └── traces/
    │       ├── system/
    │       ├── workload/
    │       ├── processed/
    │       ├── plots/
    │       └── notes.md
    └── reference-runs/
        └── <reference-id>/
```

Each execution produces an **evidence bundle** containing the information required to understand and analyze that run:

- `manifest.yaml` records identity, source revision, environment, capture window, and timeline events.
- `telemetry/` contains metrics, logs, and traces collected during the continuous capture window.
- `system/` contains supporting state such as Kubernetes events, resource descriptions, PostgreSQL statistics, or Redis information.
- `workload/` contains load generator output and effective workload configuration.
- `processed/` contains normalized, filtered, or aggregated data derived from the captured evidence.
- `plots/` contains generated figures and visualizations.
- `notes.md` contains observations specific to the execution.

Run identifiers should be unique and sortable. A UTC timestamp is the preferred initial convention, for example `2026-09-18T153000Z`.

## Local And Reference Runs

The `runs/` directory is intended for complete local executions and should be ignored by Git by default. These outputs may be large, environment-specific, or reproducible from their experiment definitions.

The `reference-runs/` directory is reserved for selected, documented executions that support project documentation, demonstrations, or significant findings. A reference run should be stable, sanitized, reasonably sized, and traceable to its experiment definition and source revision. Large reference datasets may eventually be distributed as release artifacts instead of being committed directly to Git.

The mechanism for loading historical reference runs into Grafana or another visualization environment is intentionally left open. It will be designed after real experiments establish which export formats are reliable, portable, and useful.

Every retained result must remain traceable to an experiment definition, platform version, workload configuration, execution environment, and capture window.
