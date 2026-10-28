# Changelog

All notable changes to this chart are documented here. The chart follows [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-10-28

### Added
- Initial release with Logto `1.45.0` (official `svhd/logto` image).
- Built-in PostgreSQL (`postgres:17-alpine`) with generated, upgrade-stable password.
- External PostgreSQL via URL or existing secret (CloudNativePG compatible).
- Gateway API `HTTPRoute` (default) and `Ingress` support.
- Automatic DB seeding and alterations via init container.
- `helm test` hook that checks `/api/status`.
