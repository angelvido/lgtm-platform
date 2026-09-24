# Contributing

Thank you for your interest in LGTM Platform. The project is currently establishing its architecture and development conventions, so early contributions should favor clarity, focused scope, and explicit reasoning.

## Project Language

English is the primary language for source code, configuration, documentation, issues, and pull requests.

## Contribution Principles

- Keep changes small and focused on one concern.
- Avoid introducing infrastructure or dependencies without a concrete requirement.
- Preserve the separation between cluster infrastructure, shared observability, applications, and experiments.
- Document significant technical decisions with an Architecture Decision Record.
- Do not describe planned capabilities as already implemented.
- Include validation instructions and relevant documentation with functional changes.

## Development Workflow

1. Open an issue or discussion for substantial architectural changes.
2. Create a focused branch from the default branch.
3. Make the smallest change that satisfies the agreed scope.
4. Run the repository validation suite and any additional checks documented by the affected component.
5. Submit a pull request explaining the motivation, approach, validation, and trade-offs.

Additional build and test instructions will be added as executable components are introduced.

## Validation

Before submitting a pull request, run:

```bash
make lint
```

This command runs the same repository, shell, YAML, and Helm validation used by GitHub Actions. The current validation dependencies are:

- ShellCheck.
- yamllint.
- Helm 4.

Validation tooling reports missing dependencies but does not install them automatically.

## Architecture Decisions

Changes that establish or significantly alter architecture should include an ADR under `docs/decisions/`. Use the repository template and record both the benefits and consequences of the decision.

## Experimental Changes

Experiment definitions should state their objective, controlled variables, workload, duration, injected condition, observed signals, and expected outputs. Experimental results should remain distinguishable from configuration and source code.

## Licensing

By contributing to this repository, you agree that your contributions will be licensed under the Apache License, Version 2.0.
