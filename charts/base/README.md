# How to use as dependency, basic example

```
dependencies:
  - name: base
    version: 0.1.65
    repository: https://dasmeta.github.io/helm
```

# How to set ingress default backend

```yaml
# file values.yaml
...

ingress:
  enabled: true
  class: nginx
  annotations: {}
  defaultBackend:
    service:
      name: my-backend-service
      port:
        number: 80
  hosts:
    - host: my-domain.com
      paths:
        - backend:
            serviceName: my-backend-service
            servicePort: 80
          path: /*
...
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

## \_helpers.tpl

| Helper identifier         | Description  | Expected Input              | Default Value             |
| ------------------------- | --------------------------------------------------------------------------------------------- | --------------------------- | ------------------------- |
| `base.name`               | The name of the chart.           | .Values.name                | .Chart.Name               |
| `base.fullname`           | Fully qualified app name. If release name contains chart name it will be used as a full name. | .Values.fullnameOverride    | .Release.Name             |
| `base.version`            | The version of the chart.        | .Values.version             | .Chart.Version            |
| `base.appVersion`         | The appVersion of the chart.     | .Values.appVersion          | .Chart.AppVersion         |
| `base.chart`              | It's made of base.name and base.version.             | ---    | ---  |
| `base.labels`             | Common labels. ---    | ---  |
| `base.selectorLabels`     | Selector labels.                 | ---    | ---  |
| `base.serviceAccountName` | The name of the service account to use.              | .Values.serviceAccount.name | base.fullname / "default" |

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
  class: alb
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
In this case, labels will be like this:\*\*

- `helm.sh/chart: base-0.1.36 `
- `app.kubernetes.io/name: base`
- `app.kubernetes.io/version: 0.1.36 `

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
    version: 0.1.36
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
    version: 0.1.36
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
    version: 0.1.36
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

**The PVC has a specific name**

```
my-app-base:
  ...
  deployment:
    volumes:
    - name: test-volume
      persistentVolumeClaim:
        claimName: volume-1
```

**The PVC has the name of the release**

```
my-app-base:
  ...
  deployment:
    volumes:
    - name: test-volume
      persistentVolumeClaim:
        dynamicName: true
```

**Volume type is emptyDir**

```
my-app-base:
  ...
  deployment:
    volumes:
      - name: dshm
        mountPath: /dev/shm
        emptyDir:
          medium: Memory
          sizeLimit: 2G
```

### PVC

By defining `storage` block in values.yaml file you can create a PVC resource.

```
my-app-base:
  ...
  storage:
    className: aws-efs
    accessModes:
      - ReadWriteOnce
    requestedSize: 4Gi
```


### Ingress

By default ingress class is alb and chart attache alb ingress controller annotations.

#### Ingress Class ALB
Default ALB Annotations
```
kubernetes.io/ingress.class: alb
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/group.order: 20
alb.ingress.kubernetes.io/healthcheck-path: /
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80},{"HTTPS":443}]'
alb.ingress.kubernetes.io/success-codes: 200-399
```
You need add alb group.name. You can add more annotations or overwrite existing ones.
```
  ingress:
    enabled: true
    class: alb
    annotations:
     alb.ingress.kubernetes.io/group.name: dev-orders-co
    hosts:
      - host: partners.dev.orders.co
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: web-partners
              port: 80
```
#### Ingress Class Application Gateway
Default Application Gateway Annotations
```
kubernetes.io/ingress.class: azure/application-gateway
external-dns.alpha.kubernetes.io/ttl: 60
appgw.ingress.kubernetes.io/backend-protocol: http
appgw.ingress.kubernetes.io/ssl-redirect: true
```
You can add more annotations or overwrite existing ones.
```
  ingress:
    enabled: true
    class: application-gateway
    annotations: {}
    hosts:
      - host: partners.dev.orders.co
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: web-partners
              port: 80
```

#### Ingress Class CCE
Default CCE Annotations
```
kubernetes.io/ingress.class: cce
kubernetes.io/elb.port: 443
```
You can add more annotations or overwrite existing ones.
```
  ingress:
    enabled: true
    class: cce
    annotations: {}
    hosts:
      - host: partners.dev.orders.co
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: web-partners
              port: 80
```

#### Ingress Class Nginx
Default Nginx  Annotations
```
kubernetes.io/ingress.class: nginx
```
You can add more annotations or overwrite existing ones.
```
  ingress:
    enabled: true
    class: nginx
    annotations: {}
    hosts:
      - host: partners.dev.orders.co
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: web-partners
              port: 80
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

### ExteraContainer
If you have two container in one deployment you can use extraContainer parameter.

```
base:
  extraContainer:
    name: nginx
    containerPort: 80
    image:
      repository: nginx:1.22-alpine
      pullPolicy: IfNotPresent
      tag: latest
    resources:
      limits:
        cpu: 500m
        memory: 128Mi
      requests:
        cpu: 250m
        memory: 64Mi
    deployment:
      volumes:
        - name: config
          mountPath: /etc/nginx/conf.d/nginx.conf
          // Assign volumes on extra container
          container: extra
          configMap:
            name: config
    service:
      enabled: false
    configmap:
      name: config
      config:
        nginx.conf: |
          server {
            listen 80;
            server_name ********;
            resolver kube-dns.kube-system.svc.cluster.local valid=10s;
            location /healthcheck {
              return 200 'healthy\n';
            }
          }
```

### If you want add pod extra label
```
  base:
   labels:
     label1:
       name: "app-version"
       value: "v1.0.19"
```

### If you want add topologySpreadConstraints for your deployment.

  topologySpreadConstraints:
    - labelSelector:
        matchLabels:
          app.kubernetes.io/name: base-fullname
      maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: ScheduleAnyway
    - labelSelector:
        matchLabels:
          app.kubernetes.io/name: base-fullname
      maxSkew: 2
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: ScheduleAnyway

### Connect to external configmap

  externalConfigmap:
    name: docflow-config

### Init container
####  0.1.66 Version which support one init container
initContainers:
  name: config
  args:
  - /config.json
  - /test/config.json
  secrets:
    - CLIENT_ID:
        from: client-market
        key: client_id
    - AUTH_TOKEN:
        from: auth-token
        key: token
  image:
    repository: nginx
    pullPolicy: IfNotPresent
    tag: latest
  volumes:
    - mountPath: /config.json
      name: config-json
      subPath: config.json

#### 0.2.0 version support multiple init containers
initContainers:
  - name: config
    args:
    - /config.json
    - /test/config.json
    secrets:
      - CLIENT_ID:
          from: client-market
          key: client_id
      - AUTH_TOKEN:
          from: auth-token
          key: token
    image:
      repository: nginx
      pullPolicy: IfNotPresent
      tag: latest
    volumes:
      - mountPath: /config.json
        name: config-json
        subPath: config.json

#### the version 0.2.1 supports both new multiple/list and single-map/old initContainers config formats

### Job 
  job:
    name: db-commands
    annotations:
        "helm.sh/hook": pre-install,pre-upgrade
    image:
      repository: ********.dkr.ecr.eu-central-1.amazonaws.com/
      tag: latest
      pullPolicy: IfNotPresent
   labels:
     label1:
       name: "app-version"
       value: "v1.0.19"
    volumes:
    - name: storage
      mountPath: /opt/storage/
    envFrom:
        secret: api
    command:
      - "/bin/bash"
      - "-c"
      - |
        env > .env

### Deployment read full secret

  envFrom:
    secret: site-stage

### Deployment add additionalvolume mount path for same pvc

  deployment:
    volumes:
      - name: storage
        mountPath: /storage/aaaa
        subPath: aaaa
        persistentVolumeClaim:
          claimName: storage

    additionalvolumeMounts:
      - name: storage
        mountPath: /storage/bbbb
        subPath: bbbb
  
### Deployment send command and args

  command:
    - "/bin/bash"
    - "-c"
  args:
    - |
      /test.sh


### Deployment use terminationGracePeriodSeconds parameter
terminationGracePeriodSeconds: 65

### Deployment use chart-hooks
annotations:
  "helm.sh/hook": pre-install,pre-upgrade


### custom rollout strategy(canary,blue/gree) configs by using flagger
```yaml
# This config allows to enable custom rollout strategies by using different providers/operators
# right now only flagger (https://flagger.app/) operator supported and tested for canary with nginx
## NOTE for flagger operator:
## - flagger supports several service meshes and ingresses as provider for traffic splitting, and by default we have using nginx here, so you have to check docs and have at least one used for you app
## - you need to have flagger tool/operator already installed to be able to use its crd, this can be done by installing flagger helm https://artifacthub.io/packages/helm/flagger/flagger
## - also there is need to have at least one metric server/provider enabled(it supports) like prometheus as it uses metrics for checking success rates, the flagger helm allows to install prometheus
## - with flagger enabled we disable native kubernetes service as flagger creates/overrides this service
## - with separate installed prometheus operator(not one that comes with flagger helm) the default `request-success-rate` and `request-duration` metrics templates may not work so you may need to create custom metric templates, the canary+nginx+prometheus metric template can be created by using `dasmeta/flagger-metric-template` chart
rolloutStrategy:
  enabled: true
  operator: flagger
  configs: # here are all supported flagger configs
    provider: nginx # the flagger ingress/service-mesh provider (default nginx)
    progressDeadlineSeconds: 61 # the maximum time in seconds for the canary deployment to make progress before it is rollback (default 600s)
    canaryReadyThreshold: 51 # minimum percentage of canary pods that must be ready before considering canary ready for traffic shifting (default 100)
    primaryReadyThreshold: 51 # minimum percentage of primary pods that must be ready before considering primary ready for traffic shifting (default 100)
    interval: 11s # schedule interval (default 60s)
    threshold: 11 # max number of failed metric checks before rollback (default 10)
    maxWeight: 31 # max traffic percentage (0-100) routed to canary (default 30)
    stepWeight: 11 # canary increment step percentage (0-100) (default 10)
    # min and max replicas count for primary hpa, default to main app hpa, the main app hpa values also being used for canary deploy hpa so we use this options to have custom values for primary hpa
    primaryScalerMinReplicas: 3
    primaryScalerMaxReplicas: 7
    metrics: # metrics template configs to use for identifying if canary deploy handles request normally, the `request-success-rate` and `request-duration` named ones are available by default, and you can create custom metric templates
      - name: request-success-rate
        # minimum req success rate (non 5xx responses) percentage (0-100)
        thresholdRange:
          min: 99
        interval: 1m
      - name: request-duration
        # maximum req duration P99, milliseconds
        thresholdRange:
          max: 500
        interval: 1m
      # - name: request-success-rate-nginx-custom
      #   interval: 1m
      #   templateRef:
      #     name: request-success-rate-nginx-custom
      #     namespace: ingress-nginx
      #   # minimum req success rate (non 5xx responses) percentage (0-100)
      #   thresholdRange:
      #     min: 99
      # - name: request-duration-nginx-custom
      #   interval: 1m
      #   templateRef:
      #     name: request-duration-nginx-custom
      #     namespace: ingress-nginx
      #   # maximum req duration P99, milliseconds
      #   thresholdRange:
      #     max: 500
    webhooks: # (optional) webhooks can be used for load testing before traffic switching to canaries by using `pre-rollout` type and also generating traffic
      - name: acceptance-test
        type: pre-rollout
        url: http://flagger-loadtester.localhost/
        timeout: 30s
        metadata:
          type: bash
          cmd: "curl -sd 'test' http://http-echo-canary/ping | grep ping"
      - name: load-test
        url: http://flagger-loadtester.localhost/
        timeout: 5s
        metadata:
          cmd: "hey -z 1m -q 3 -c 1 http://http-echo.localhost/ping"
    alerts: # (optional) alerts allow to setup custom alerting/notify based on flaggers alert provider crd(there is also option to set global alert config with flagger), for more info look https://docs.flagger.app/usage/alerting
      - name: "on-call Slack"
        severity: error
        providerRef:
          name: on-call
          namespace: ingress-nginx
```
