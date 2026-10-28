# Contributing

Issues and pull requests are welcome.

## Development

Requirements: [Helm](https://helm.sh) 3.8+ and, optionally, [chart-testing](https://github.com/helm/chart-testing).

```bash
helm lint charts/logto --strict
helm template test charts/logto -f examples/gateway-api.yaml
ct lint --config ct.yaml
```

Try it on a local cluster (kind, k3d, minikube):

```bash
helm install logto charts/logto -n logto --create-namespace --wait
helm test logto -n logto
```

## Pull request checklist

- Bump `version` in `charts/logto/Chart.yaml` for any chart change (CI enforces this).
- Bump `appVersion` when moving to a new Logto release.
- Update `charts/logto/README.md` when adding or changing values.
- Add an entry to `CHANGELOG.md`.
