# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for significant technical choices.

ADRs provide a durable record of the context, decision, alternatives, and consequences associated with the project's architecture. They are intended to support both project maintenance and later technical evaluation.

## Naming

Use a sequential identifier and a short descriptive title:

```text
0001-use-a-monorepo.md
0002-use-kind-for-local-kubernetes.md
```

## Status

Use one of the following statuses:

- `Proposed` — under active consideration.
- `Accepted` — approved for the project.
- `Deprecated` — retained for historical context but no longer recommended.
- `Superseded` — replaced by a later ADR, which should be linked.

## Process

1. Copy `template.md` to the next available sequential filename.
2. Describe the forces and constraints without assuming the decision.
3. Record the selected option and meaningful alternatives.
4. State both positive and negative consequences.
5. Update the status when the decision is accepted or replaced.

ADRs should remain concise. Detailed operational instructions belong elsewhere in the documentation.
