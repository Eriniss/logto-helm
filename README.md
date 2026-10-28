# Logto Helm Chart

[![Lint and Test](https://github.com/Eriniss/logto-helm/actions/workflows/lint-test.yaml/badge.svg)](https://github.com/Eriniss/logto-helm/actions/workflows/lint-test.yaml)
[![Release](https://github.com/Eriniss/logto-helm/actions/workflows/release.yaml/badge.svg)](https://github.com/Eriniss/logto-helm/actions/workflows/release.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A simple Helm chart for [Logto](https://logto.io), the open-source auth infrastructure (OIDC, OAuth 2.1, SAML, SSO, MFA).

- **Official images only**: [`svhd/logto`](https://hub.docker.com/r/svhd/logto) and [`postgres`](https://hub.docker.com/_/postgres).
- **PostgreSQL your way**: a built-in single-instance PostgreSQL by default, or any external database such as [CloudNativePG](https://cloudnative-pg.io).
- **Gateway API first**: `HTTPRoute` by default, classic `Ingress` when you need it.
- **Zero-touch migrations**: DB seeding and alterations run automatically on install and upgrade.
- **Small**: a handful of templates and a short `values.yaml`.

## Install

From the Helm repository:

```bash
helm repo add logto https://eriniss.github.io/logto-helm
helm repo update
helm install logto logto/logto -n logto --create-namespace
```

Or from the OCI registry:

```bash
helm install logto oci://ghcr.io/eriniss/charts/logto -n logto --create-namespace
```

With no values, Logto runs with the built-in PostgreSQL and nothing is exposed. Open it with port-forward:

```bash
kubectl -n logto port-forward svc/logto 3001 3002
```

Then go to http://localhost:3002 to create the first (admin) account.

## Expose it

Set the public URLs and point the chart at your Gateway:

```yaml
# values.yaml
endpoint: https://auth.example.com          # Logto core (sign-in, OIDC)
adminEndpoint: https://auth-admin.example.com  # Admin Console (omit to keep it private)
httpRoute:
  parentRefs:
    - name: my-gateway
      namespace: gateway
```

```bash
helm upgrade --install logto logto/logto -n logto -f values.yaml
```

Using an Ingress controller, an external database or CloudNativePG instead? See [examples/](examples/).

## Documentation

- [Chart reference: all values, external databases, upgrades](charts/logto/README.md)
- [Examples](examples/)
- [Logto documentation](https://docs.logto.io)

## Requirements

- Kubernetes 1.25+
- Helm 3.8+
- For `httpRoute`: [Gateway API](https://gateway-api.sigs.k8s.io) v1 CRDs and a Gateway controller
- For the built-in PostgreSQL: a default StorageClass (or set `postgresql.persistence.storageClass`)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Changes are tracked in [CHANGELOG.md](CHANGELOG.md).

## License

[MIT](LICENSE). This is a community chart, not affiliated with or endorsed by Logto (Silverhand Inc.). Logto itself is licensed under [MPL-2.0](https://github.com/logto-io/logto/blob/master/LICENSE).
