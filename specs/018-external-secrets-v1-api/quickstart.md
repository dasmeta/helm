# Quickstart: External Secrets v1 API Default

Run these commands from the repository root.

## Chart lint

```bash
helm lint ./charts/base ./charts/namespaces-and-docker-auth
```

Expected: `0 chart(s) failed`.

## Base default render

```bash
helm template base-es ./charts/base --set product=my-product --set env=production --set 'secrets[0]=secret1' -s templates/external-secrets.yaml
```

Expected: one `ExternalSecret` with `apiVersion: external-secrets.io/v1`.

## Base override render

```bash
helm template base-es ./charts/base --set product=my-product --set env=production --set 'secrets[0]=secret1' --set externalSecretsApiVersion=external-secrets.io/v1beta1 -s templates/external-secrets.yaml
```

Expected: the same resource with `apiVersion: external-secrets.io/v1beta1`.

## Docker auth default render

```bash
helm template nda ./charts/namespaces-and-docker-auth --set dockerAuth.enabled=true --set dockerAuth.serviceAccountRoleArn=arn:aws:iam::111122223333:role/docker-registry-auth
```

Expected: `ClusterSecretStore` and `ClusterExternalSecret`, both on `external-secrets.io/v1`.

## New example

```bash
helm template nda ./charts/namespaces-and-docker-auth -f ./examples/namespaces-and-docker-auth/docker-auth-api-version.yaml
```

Expected: both cluster-scoped resources on `external-secrets.io/v1beta1`.

## Existing example regression

```bash
helm template nda-minimal ./charts/namespaces-and-docker-auth -f ./examples/namespaces-and-docker-auth/minimal.yaml
for f in ./examples/base/*.yaml; do helm template base-example ./charts/base -f "$f" >/dev/null || echo "FAILED: $f"; done
```

Expected: each command exits with status `0` and nothing is reported as failed.
