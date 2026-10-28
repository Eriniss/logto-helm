# Examples

Ready-to-use values files. Replace `example.com` hostnames and the Gateway reference with your own.

| File | What it shows |
| --- | --- |
| [gateway-api.yaml](gateway-api.yaml) | Gateway API `HTTPRoute` + built-in PostgreSQL (the default setup) |
| [ingress-nginx.yaml](ingress-nginx.yaml) | Classic `Ingress` with ingress-nginx and cert-manager |
| [private-admin-console.yaml](private-admin-console.yaml) | Public core, Admin Console only via port-forward |
| [external-database.yaml](external-database.yaml) | Any external PostgreSQL via an existing secret or URL |
| [cloudnative-pg/](cloudnative-pg/) | CloudNativePG `Cluster` manifest + matching values |
| [gitops.yaml](gitops.yaml) | Argo CD / Flux: built-in PostgreSQL with a password from your own secret |
| [production.yaml](production.yaml) | CNPG, 2 replicas, anti-affinity, resources, pinned tag |

```bash
helm install logto logto/logto -n logto --create-namespace -f examples/gateway-api.yaml
```
