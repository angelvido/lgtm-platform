# Experiment: Descriptive Title

## Status

Planned

## Objective

State the question the experiment is intended to answer.

## Hypothesis

Describe the expected behavior or relationship, if the experiment is hypothesis-driven.

## Environment

Record the relevant hardware, operating system, Kubernetes version, platform revision, application revision, and component configuration.

## Capture Window

Define when evidence collection starts and ends relative to the workload and condition under study. The capture window should begin early enough to establish normal behavior and end after the effects or recovery have been observed.

## Workload

Describe the traffic model, concurrency, request rate, test data, warm-up period, and total duration.

## Introduced Condition

Describe the load, degradation, failure, or configuration change being evaluated. Use `None` for a baseline experiment.

## Observed Variables

List the metrics, logs, traces, alerts, resource measurements, and application outcomes that will be collected.

## Timeline Events

Define the events that must be timestamped during execution, such as workload start, traffic changes, condition introduction, condition removal, recovery, and capture completion.

## Procedure

1. Define the initial platform state.
2. Describe the exact execution steps.
3. Define completion and abort conditions.
4. Describe cleanup and environment restoration.

## Expected Outputs

Describe the expected evidence bundle, including telemetry, supporting system state, workload output, processed data, plots, and execution notes.

## Evidence Location

Record the expected location under `results/<experiment-id>/runs/<run-id>/` and state whether a successful execution may later be promoted to a reference run.

## Results

Record the measured outcomes after execution. Link to retained artifacts under `results/` when applicable.

## Analysis

Interpret the results in relation to the objective and hypothesis. Separate observations from explanations.

## Limitations

Document confounding variables, measurement limitations, environmental constraints, and threats to validity.
