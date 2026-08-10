# Render Contract: External Secrets v1 API Default

## `charts/base` — default render

Command:

```bash
helm template base-es ./charts/base --set product=my-product --set env=production --set 'secrets[0]=secret1' -s templates/external-secrets.yaml
```

Expected output:

- Renders one `ExternalSecret`.
- `apiVersion` is `external-secrets.io/v1`.
- `spec.refreshInterval`, `spec.secretStoreRef`, `spec.target` and `spec.data` are identical to the previous chart release.

## `charts/base` — override to the previous version

Command:

```bash
helm template base-es ./charts/base --set product=my-product --set env=production --set 'secrets[0]=secret1' --set externalSecretsApiVersion=external-secrets.io/v1beta1 -s templates/external-secrets.yaml
```

Expected output:

- `apiVersion` is `external-secrets.io/v1beta1`.
- All other fields unchanged.

## `charts/base` — suppression guards

- With an empty `secrets` list, no `ExternalSecret` is rendered.
- With `secretsDefaultEngine` set to anything other than `ExternalSecrets`, no `ExternalSecret` is rendered.

## `charts/namespaces-and-docker-auth` — default render

Command:

```bash
helm template nda ./charts/namespaces-and-docker-auth --set dockerAuth.enabled=true --set dockerAuth.serviceAccountRoleArn=arn:aws:iam::111122223333:role/docker-registry-auth
```

Expected output:

- Renders both a `ClusterSecretStore` and a `ClusterExternalSecret`.
- Both carry `apiVersion: external-secrets.io/v1`.
- `spec.provider.aws.auth.jwt.serviceAccountRef`, `spec.namespaceSelector`, `spec.refreshTime` and the whole `spec.externalSecretSpec` block are unchanged, including the `dockerconfigjson` template at `engineVersion: v2`.

## `charts/namespaces-and-docker-auth` — override to the previous version

Command:

```bash
helm template nda ./charts/namespaces-and-docker-auth -f ./examples/namespaces-and-docker-auth/docker-auth-api-version.yaml
```

Expected output:

- Both cluster-scoped resources carry `apiVersion: external-secrets.io/v1beta1`.
- Rendered output is otherwise byte-identical to the default render.

## `charts/namespaces-and-docker-auth` — suppression guard

With `dockerAuth.enabled: false`, neither the `ClusterSecretStore` nor the `ClusterExternalSecret` is rendered.

## Regression

Existing examples for both charts must continue to render without behavior changes:

- `examples/base/*.yaml`
- `examples/namespaces-and-docker-auth/minimal.yaml`
