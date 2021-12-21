```
dependencies:
  - name: base
    version: 0.1.16
    repository: https://dasmeta.github.io/helm
```

```bash
$ helm dependency update
$ helm install my-app .
```

## Introduction

This chart provides a base template helpers which can be used to develop new charts using [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.18+
- Helm 3.7.1

## _helpers.tpl

| Helper identifier                              | Description                                                                                    | Expected Input    | Default Value    |
|------------------------------------------------|------------------------------------------------------------------------------------------------|-------------------|-------------------|
| `base.name`              | The name of the chart. | .Values.name | .Chart.Name    |
| `base.fullname`       | Fully qualified app name. If release name contains chart name it will be used as a full name.                                                 | .Values.fullnameOverride | .Release.Name    |
| `base.version`    | The version of the chart.                                              | .Values.version | .Chart.Version    |
| `base.appVersion`   | The appVersion of the chart.                                             | .Values.appVersion | .Chart.AppVersion    |
| `base.chart`       | It's made of base.name and base.version.                                                 | --- |  ---  |
| `base.labels`          | Common labels.                                          | --- | ---    |
| `base.selectorLabels`           | Selector labels.                                                    | --- | ---    |
| `base.serviceAccountName`        | The name of the service account to use.                                       | .Values.serviceAccount.name | base.fullname / "default"    |

## Default Values
```
replicaCount: 1
image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: 1.21
imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""
serviceAccount:
  create: true
  annotations: {}
  name: ""
podAnnotations: {}
podSecurityContext: {}
securityContext: {}
service:
  type: NodePort
  port: 80
ingress:
  enabled: false
  annotations: {}
  hosts:
    - host: host.name.com
      paths:
      - path: /*
        backend:
          serviceName: ssl-redirect
          servicePort: use-annotation
      - backend:
          serviceName: base
          servicePort: 80
        path: /*
  tls: []
resources: {}
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
nodeSelector: {}
tolerations: []
affinity: {}
config: {}
containerPort: 80
livenessProbe: {}
readinessProbe: {}
deployment: {}
env: dev
product: application
secrets: {}
```

## Problems
If you want your chart to have the name `my-app-base` you have to specify it in Chart.yaml file by passing it to `alias`. After everything has to be defined under the alias name(in this case under `my-app-base`) in your values.yaml file. Otherwise, it will get the name `base`. It's a problem that has no dynamic solution in helm. The same problem is with the version and appVersion. Your parent chart will receive `base`'s version if you do not change them by these 2 variables: `version`, `appVersion`. None of these is a mandatory value, so without them, you will have no problem in the process of running the chart.
Here are 2 examples about this:

### Example 1
**Alias is not specified, name, version and appVersion are not overridden by parent chart**
In this case, labels will be like this:**

- `helm.sh/chart: base-0.1.16`
- `app.kubernetes.io/name: base`
- `app.kubernetes.io/version: 0.1.16`

Chart.yaml
```
apiVersion: v2
name: my-application
description: My application service description
type: application
version: 0.1.0
appVersion: "0.1.0"

dependencies:
  - name: base
    version: 0.1.16
    repository: https://dasmeta.github.io/helm
```

values.yaml

These are mandatory values you should provide.
```
base:
  image:
    repository: docker-image
    tag: 1.2.3
```

### Example 2
**Alias is specified/or name is overriden, also version and appVersion are overridden by parent chart**
Now if you prefer to change your chart's name and version, you can do it by the alias variable(passing a name to it in Chart.yaml) or you can override the `name` in values.yaml file. The result will be the same. About `version` and `appVersion`, they have to be changed in values.yaml.
The same labels, given above, now will be:

- `helm.sh/chart: my-app-base-0.1.0`
- `app.kubernetes.io/name: my-app-base`
- `app.kubernetes.io/version: 0.1.0`

**This is with the alias name.**

Chart.yaml
```
apiVersion: v2
name: my-application
description: My application service description
type: application
version: 0.1.0
appVersion: "0.1.0"

dependencies:
  - name: base
    version: 0.1.16
    repository: https://dasmeta.github.io/helm
    alias: my-app-base
```

values.yaml
```
my-app-base:
  version: 0.1.0
  appVersion: 0.1.0
  image: 
    repository: docker-image
    tag: 1.2.3
```

**This is by overridding the `name`.**

Chart.yaml
```
apiVersion: v2
name: my-application
description: My application service description
type: application
version: 0.1.0
appVersion: "0.1.0"

dependencies:
  - name: base
    version: 0.1.16
    repository: https://dasmeta.github.io/helm
```

values.yaml
```
base:
  name: my-app-base
  version: 0.1.0
  appVersion: 0.1.0
  image: 
    repository: docker-image
    tag: 1.2.3
```

### External secrets
This will produce external secrets which will ask secrets from store `my-app-production`.
Values in Secrets Manager should be put in `my-product/production/my-app` matching secret1, secret2, secret2.
You have to previously create a Secret Store. Check our `external-secret-store` module in Terraform Registry.
```
my-app-base:
  ...
  product: my-product
  env: production
  secrets:
    - secret1
    - secret2
    - secret3
```

### Volumes
```
my-app-base:
  ...
  deployment:
    volumes:
    - name: test-volume
      persistentVolumeClaim:
        claimName:
```

### Health Checks
```
livenessProbe: {}
  failureThreshold: 3
  httpGet:
    path: /
    port: 80
    scheme: HTTP
  initialDelaySeconds: 60
  periodSeconds: 5
  successThreshold: 1
  timeoutSeconds: 1

readinessProbe: {}
  httpGet:
    path: /
    port: http
  initialDelaySeconds: 60
  periodSeconds: 5
```
