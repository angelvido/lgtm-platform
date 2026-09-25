# ADR-0003: Reference Existing Kubernetes Secrets

- **Status:** Accepted
- **Date:** 2026-09-24
- **Decision owners:** Project maintainers

## Context

The platform requires credentials, tokens, private keys, and certificates that must not be committed to Git or embedded in Helm values. Local development still needs a reproducible way to create the required Kubernetes Secrets without introducing a production secret manager prematurely.

## Decision

Helm charts reference existing Kubernetes Secrets by stable name and key. They do not contain sensitive values or render project-owned credentials directly.

For local development, secret material is stored as files under the ignored `.secrets/` directory. Deployment scripts create or update Kubernetes Secrets from those files without printing their contents. Tracked documentation under `.secrets.example/` defines expected filenames and setup commands without containing real secrets.

Shared and production environments should provide the same Kubernetes Secret contract through an external secret manager or environment-specific provisioning process.

## Consequences

### Positive

- Sensitive values remain outside Git history and Helm values.
- Local development remains simple and reproducible.
- Charts remain independent from the mechanism used to provision secrets.
- A future external secret manager can replace local helpers without changing application configuration.

### Negative

- Developers must create required local secret files before deployment.
- Kubernetes Secrets remain base64-encoded resources rather than encrypted storage by themselves.
- Secret rotation requires rerunning the relevant provisioning or deployment command.

## Follow-Up

- Apply the same existing-Secret pattern to future database credentials, API tokens, TLS private keys, and certificates.
- Evaluate an external secret manager only when shared or remote environments require it.
- Avoid exposing secret values in CI logs, command output, or experiment results.
