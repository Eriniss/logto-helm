# Logto Helm Chart

Deploys [Logto](https://logto.io) with the official [`svhd/logto`](https://hub.docker.com/r/svhd/logto) image.

- Built-in PostgreSQL (official `postgres:17-alpine`, single StatefulSet) by default, or any external PostgreSQL (e.g. CloudNativePG).
- Gateway API `HTTPRoute` by default, or a classic `Ingress`.
- DB seeding and alterations run automatically in an init container (no-ops when up to date).

## Install

```bash
helm repo add logto https://eriniss.github.io/logto-helm
helm install logto logto/logto -n logto --create-namespace
# or: helm install logto oci://ghcr.io/eriniss/charts/logto -n logto --create-namespace

kubectl -n logto port-forward svc/logto 3001 3002
# Admin Console: http://localhost:3002
```

The first account registered in the Admin Console becomes the admin, so register right after exposing it.

Check the deployment with `helm test logto -n logto`.

## Gateway API (default)

Routes are created once `endpoint` is set. Hostnames are taken from `endpoint` / `adminEndpoint`, and one `HTTPRoute` is created per hostname.

```yaml
endpoint: https://auth.example.com
adminEndpoint: https://auth-admin.example.com   # omit to keep the console private
httpRoute:
  parentRefs:
    - name: my-gateway
      namespace: gateway
      sectionName: https
```

TLS is terminated at the Gateway; `trustProxyHeader: true` (default) makes Logto honour `X-Forwarded-*`.

## Ingress

```yaml
endpoint: https://auth.example.com
adminEndpoint: https://auth-admin.example.com
httpRoute:
  enabled: false
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
  tlsSecretName: logto-tls
```

## External database

Use either a URL or an existing secret:

```yaml
postgresql:
  enabled: false
externalDatabase:
  url: postgresql://logto:secret@db.example.com:5432/logto
  # or
  existingSecret: my-db-secret
  existingSecretKey: uri
```

The DB user needs the `CREATEROLE` privilege: Logto's seed creates `logto_tenant_*` roles. Without it the `migrate` init container fails with `permission denied to create role`.

### CloudNativePG

CNPG's `<cluster>-app` secret already has a `uri` key. Give the owner `CREATEROLE` through managed roles:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: logto-pg
spec:
  instances: 3
  storage:
    size: 10Gi
  bootstrap:
    initdb:
      database: logto
      owner: logto
  managed:
    roles:
      - name: logto
        ensure: present
        login: true
        createrole: true
```

```yaml
postgresql:
  enabled: false
externalDatabase:
  existingSecret: logto-pg-app
```

More in [examples/](https://github.com/Eriniss/logto-helm/tree/main/examples).

## Values

| Key | Default | Description |
| --- | --- | --- |
| `image.repository` / `image.tag` | `svhd/logto` / appVersion | Logto image |
| `image.pullPolicy` | `IfNotPresent` | Image pull policy |
| `imagePullSecrets` | `[]` | Pull secrets (also used by PostgreSQL) |
| `replicaCount` | `1` | Logto replicas |
| `endpoint` | `""` | Public core URL (`ENDPOINT`); enables routes/ingress |
| `adminEndpoint` | `""` | Public Admin Console URL (`ADMIN_ENDPOINT`); empty = not exposed |
| `trustProxyHeader` | `true` | Sets `TRUST_PROXY_HEADER=1` |
| `migrations.enabled` | `true` | Run `db seed --swe` + `db alteration deploy latest` before start |
| `extraEnv` / `extraEnvFrom` | `[]` | Extra env for Logto (list of `EnvVar` / `EnvFromSource`) |
| `resources` | `{}` | Logto container resources |
| `podAnnotations` / `podLabels` | `{}` | Extra pod metadata |
| `podSecurityContext` / `securityContext` | `{}` | Pod / container security contexts |
| `nodeSelector` / `tolerations` / `affinity` | `{}` / `[]` / `{}` | Scheduling |
| `service.type` | `ClusterIP` | Service type |
| `service.port` / `service.adminPort` | `3001` / `3002` | Core / Admin Console ports |
| `postgresql.enabled` | `true` | Built-in PostgreSQL |
| `postgresql.image.repository` / `tag` | `postgres` / `17-alpine` | PostgreSQL image |
| `postgresql.auth.username` / `database` | `logto` / `logto` | DB user / name |
| `postgresql.auth.password` | `""` | Generated and kept across upgrades when empty |
| `postgresql.persistence.enabled` | `true` | Use a PVC (otherwise `emptyDir`) |
| `postgresql.persistence.storageClass` | `""` | Empty = cluster default |
| `postgresql.persistence.size` | `8Gi` | PVC size |
| `postgresql.resources` | `{}` | PostgreSQL container resources |
| `externalDatabase.url` | `""` | External DB URL |
| `externalDatabase.existingSecret` / `existingSecretKey` | `""` / `uri` | Secret holding the DB URL |
| `httpRoute.enabled` | `true` | Create HTTPRoutes (when `endpoint` is set) |
| `httpRoute.parentRefs` | `[]` | Gateways to attach to (required with `endpoint`) |
| `httpRoute.annotations` | `{}` | HTTPRoute annotations |
| `ingress.enabled` | `false` | Create an Ingress (when `endpoint` is set) |
| `ingress.className` / `annotations` | `""` / `{}` | Ingress class and annotations |
| `ingress.tlsSecretName` | `""` | TLS secret for both hosts; empty = no `tls` block |

## Upgrading

Upgrading the chart's `appVersion` (or `image.tag`) runs pending Logto DB alterations automatically in the `migrate` init container. **Back up the database first**: alterations cannot always be rolled back.

## Uninstalling

```bash
helm uninstall logto -n logto
```

The built-in PostgreSQL PVC (`data-logto-postgresql-0`) is kept. Delete it to remove all data:

```bash
kubectl -n logto delete pvc data-logto-postgresql-0
```

## Notes

- On a fresh install the `migrate` init container may restart a few times until PostgreSQL is ready; that's expected.
- The built-in PostgreSQL is a single instance without backups. For production, use an external/HA database such as CloudNativePG.
- With `replicaCount > 1` on a fresh database, one pod's `migrate` may fail once while another seeds; it succeeds on retry.
