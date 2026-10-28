# Changelog

All notable changes to this chart are documented here. The chart follows [Semantic Versioning](https://semver.org/).

## [0.1.1] - 2026-10-28

### Added
- `postgresql.auth.existingSecret` / `existingSecretPasswordKey`: provide the built-in PostgreSQL password from your own secret. Recommended for Argo CD / Flux, where the generated password would change on every render.
- GitOps section in the chart README and `examples/gitops.yaml`.

## [0.1.0] - 2026-10-28

### Added
- Initial release with Logto `1.45.0` (official `svhd/logto` image).
- Built-in PostgreSQL (`postgres:17-alpine`) with generated, upgrade-stable password.
- External PostgreSQL via URL or existing secret (CloudNativePG compatible).
- Gateway API `HTTPRoute` (default) and `Ingress` support.
- Automatic DB seeding and alterations via init container.
- `helm test` hook that checks `/api/status`.
