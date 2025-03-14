# This helm chart allows to create kubernetes namespaces and configure docker registries(for example dockerhub) images pull credentials secret in namespaces

## to install the chart use the command
```sh
helm upgrade --install -n default app-namespaces dasmeta/namespaces-and-docker-auth -f path-of-values.yaml
```

## examples of values.yaml files
### create namespaces
```yaml
list:
  - dev
  - stage
```

### create namespace and attach custom labels
```yaml
list:
  - dev
labels:
  mylabel: myvalue
```

### create external secrets for docker hub auth, the namespaces where 'docker-registry-auth' will be placed by default are ones having `docker-auth: enabled` label set
```yaml
dockerAuth:
  enabled: true
  refreshInterval: "1m" # default value is 1h, we set some small value to sync the aws secret manager changes quickly, but it is worth to set back to 1h after sync to not get frequent aws secret reads, which can generate some cost
  secretManagerSecretName: "docker-hub-credentials" # the default secret is `account`, but we can store the docker auth credentials also in custom secret like this one
```

### create namespace and docker auth secret in
```yaml
list:
  - dev
dockerAuth: # there should be secret in `eu-central-1` region named `account` and DOCKER_HUB_USERNAME/DOCKER_HUB_PASSWORD should be set in that secret
  enabled: true
```