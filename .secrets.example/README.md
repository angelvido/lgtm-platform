# Local Secret Files

The `.secrets/` directory contains local development secret material and is ignored by Git. This example directory documents the expected filenames without containing real credentials, private keys, tokens, or certificates.

## Grafana Administrator Password

Create the local password file before deploying observability:

```bash
mkdir -p .secrets
printf '%s' 'replace-with-a-local-password' > .secrets/grafana-admin-password
chmod 600 .secrets/grafana-admin-password
```

The deployment script creates or updates the `grafana-admin-credentials` Kubernetes Secret from this file. The Helm chart only references that Secret and never contains the password.

The password `admin` may be used for a disposable local laboratory, but it must not be reused in shared, remote, or production environments.

## Future Secret Material

Future credentials, tokens, private keys, and certificates should follow the same rules:

- Store local secret material under `.secrets/`.
- Commit only documentation, filenames, and non-sensitive examples under `.secrets.example/`.
- Create Kubernetes Secrets outside Helm templates.
- Configure charts to reference existing Secrets by name and key.
- Never print secret values in scripts or CI logs.
- Use a dedicated external secret manager for shared or production environments.
