## Introduction

This chart provides a base template helpers which can be used to develop new charts using [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.18+
- Helm 3.7.1

### commands
```bash
# minimal setup
helm repo add dasmeta https://dasmeta.github.io/helm # adds dasmeta helm chart into helm repos list
helm upgrade --install -n default my-test-app dasmeta/base --version 0.3.11 -f ./my-test-app.values.yaml # create/change helm release, you have to have ./my-test-app.values.yaml created, check examples to know how to create/configure it

# to get diff and debug check what will be created/changed on apply
helm plugin install https://github.com/databus23/helm-diff # to install helm diff plugin
helm diff upgrade --install -n default my-test-app dasmeta/base --version 0.3.11 -f ./my-test-app.values.yaml # shows diff of what will be create/changed

# for case you have the chart as dependency
helm dependency update # in case you added `dasmeta/base` in helm chart Chart.yaml as dependency this command will pull/update dependency
helm upgrade --install my-app . # allows to run current directory helm chart
```

### The default values and related description/examples can be found in [./values.yaml](./values.yaml) file

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

```yaml
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

```yaml
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

```yaml
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

```yaml
my-app-base:
  version: 0.1.0
  appVersion: 0.1.0
  image:
    repository: docker-image
    tag: 1.2.3
```

**This is by overridding the `name`.**

Chart.yaml

```yaml
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

```yaml
base:
  name: my-app-base
  version: 0.1.0
  appVersion: 0.1.0
  image:
    repository: docker-image
    tag: 1.2.3
```

## Examples for each component (for complete working examples look into [../../examples/base](../../examples/base)) folder

### How to use as dependency, basic example

```yaml
dependencies:
  - name: base
    version: 0.3.11
    repository: https://dasmeta.github.io/helm
```

### How to set ingress default backend

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


### External secrets

This will produce external secrets which will ask secrets from store `my-app-production`.
Values in Secrets Manager should be put in `my-product/production/my-app` matching secret1, secret2, secret2.
You have to previously create a Secret Store. Check our `external-secret-store` module in Terraform Registry.

```yaml
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

```yaml
my-app-base:
  ...
  volumes:
    - name: test-volume
      persistentVolumeClaim:
        claimName: volume-1
```

**The PVC has the name of the release**

```yaml
my-app-base:
  ...
  volumes:
    - name: test-volume
      persistentVolumeClaim:
        dynamicName: true
```

**Volume type is emptyDir**

```yaml
my-app-base:
  ...
  volumes:
    - name: dshm
      mountPath: /dev/shm
      emptyDir:
        medium: Memory
        sizeLimit: 2G
```

**share volume for main and extra containers into same mount path**
```yaml
volumes:
  - emptyDir:
      medium: Memory
      sizeLimit: 10Mi
    name: volume-main-and-extra-containers
    mountPath: /volume-shared
    container: [main-container-name, extra-container-name]
```

### PVC

By defining `storage` block in values.yaml file you can create a PVC resource.

```yaml
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
```yaml
kubernetes.io/ingress.class: alb
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/group.order: 20
alb.ingress.kubernetes.io/healthcheck-path: /
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80},{"HTTPS":443}]'
alb.ingress.kubernetes.io/success-codes: 200-399
```
You need add alb group.name. You can add more annotations or overwrite existing ones.
```yaml
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
```yaml
kubernetes.io/ingress.class: azure/application-gateway
external-dns.alpha.kubernetes.io/ttl: 60
appgw.ingress.kubernetes.io/backend-protocol: http
appgw.ingress.kubernetes.io/ssl-redirect: true
```
You can add more annotations or overwrite existing ones.
```yaml
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
```yaml
kubernetes.io/ingress.class: cce
kubernetes.io/elb.port: 443
```
You can add more annotations or overwrite existing ones.
```yaml
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
```yaml
kubernetes.io/ingress.class: nginx
```
You can add more annotations or overwrite existing ones.
```yaml
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

```yaml
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

### Extra Container
If you have two or more containers in one deployment you can use extraContainer parameter.

#### single extra container by object config
```yaml
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

#### multiple extra containers with list of objects config
```yaml
extraContainer:
  - name: extra-nginx
    image:
      repository: nginx
      tag: 1.19
    extraEnv:
      NGINX_PORT: 8081
  - name: second-extra-nginx
    containerPort: 8082
    service:
      enabled: true # to have container port definition in deployment
    image:
      repository: nginx
      tag: 1.19
    extraEnv:
      NGINX_PORT: 8082
```

### If you want add pod extra label
```yaml
  base:
   labels:
     label1:
       name: "app-version"
       value: "v1.0.19"
```

### If you want add topologySpreadConstraints for your deployment. There is also default value for this starting from chart version "0.3.9". The default value allows to have preferred spread, it can be disabled by setting `spread.enabled=false`
```yaml
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
```
### Connect to external configmap
```yaml
  externalConfigmap:
    name: docflow-config
```
### Init container
####  0.1.66 Version which support one init container
```yaml
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
```
#### 0.2.0 version support multiple init containers
```yaml
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
```
#### the version 0.2.1 supports both new multiple/list and single-map/old initContainers config formats

### Job
```yaml
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
```
### Deployment read full secret
```yaml
  envFrom:
    secret: site-stage
```
### Deployment add additional volume mount path for same pvc
```yaml
  volumes:
    - name: storage
      mountPath: /storage/aaaa
      subPath: aaaa
      persistentVolumeClaim:
        claimName: storage

  additionalVolumeMounts:
    - name: storage
      mountPath: /storage/bbbb
      subPath: bbbb
  ```
### Deployment send command and args
```yaml
  command:
    - "/bin/bash"
    - "-c"
  args:
    - |
      /test.sh
```

### Deployment use terminationGracePeriodSeconds parameter
```yaml
terminationGracePeriodSeconds: 65
```
### Deployment use chart-hooks
```yaml
annotations:
  "helm.sh/hook": pre-install,pre-upgrade
```

### If you want scale deployment depends on AWS SQS queue size
```yaml
autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 3
  trigger:
    type: aws-sqs-queue
    metadata:
      queueURL: https://sqs.eu-central-1.amazonaws.com/<account-id>/<sqs-name>
      queueLength: <aws-queue-length>
      awsRegion: <aws-region>
```

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

## Deprecations and incompatible changes and release important notes

### Deprecations
 - 0.3.0: `deployment` option is deprecated and all underlying fields are now available as top level variables, so that `deployment.volumes` moved to `volumes`, `deployment.additionalvolumeMounts` to `additionalVolumeMounts` and `deployment.lifecycle` to `lifecycle`
 - 0.3.0: for mounting volume to extra container use `container: <extra-container-name>` or `container: [<extra-container-name>]` instead of `container: extra` config in new `volumes` listing.

### incompatible changes
 - 0.3.0: the `extraContainer.deployment.volumes` field have been removed, use `volumes` field with `container: <extra-container-name>` for having volume mounted to extra container

### release important notes
 - Version 0.3.8:
   This release introduces a new feature that enhances the robustness of pod termination by implementing a default preStop lifecycle hook.
    - Default preStop Hook: Version 0.3.8 introduces the `defaultLifecycle` variable, which, by default, automatically configures a preStop hook with a `sleep 5` command.
    - Graceful Pod Termination: This 5-second delay before container shutdown provides sufficient time for the pod's IP address to be unregistered from service target lists. This proactive measure minimizes the occurrence of failed HTTP requests during pod termination, leading to improved application stability and user experience.
    - sleep Command Dependency: While the absence of the sleep command within a container's operating system will prevent the 5-second delay from functioning, but will not produce any additional issues, it is strongly recommended to include or install the sleep utility in your container images to ensure the intended graceful termination behavior.
    - Custom preStop Configurations: If your containers already have custom `preStop` lifecycle configurations defined, these existing configurations will take precedence, effectively overriding the default configuration introduced in this release. However, to benefit from the graceful termination feature, it is advisable to incorporate a sleep 5 command within your custom `preStop` configurations.
    - Scope of Default Configuration: The default `preStop` configuration is applied uniformly to all containers within a pod, including the main application container and all extra containers.
    - Default Timeout Considerations: The default 5-second sleep duration has been determined through testing on standard web applications within an EKS cluster and is generally sufficient for facilitating a graceful shutdown. However, applications with longer request processing times (exceeding 2 seconds) may require an increased timeout value. You can adjust this by defining custom `preStop` configurations with a longer sleep duration.
    - Disabling the Default Configuration: The default `preStop` hook can be easily disabled by setting the Helm chart value `defaultLifecycle.enabled=false`.
 - Version 0.3.9:
   This release introduces default pod spreading rules based on the Kubernetes `topologySpreadConstraints` configuration for improved availability and resource utilization.
    - Default Pod Spreading Enabled: By default, this chart now configures pod spreading using `topologySpreadConstraints`. This aims to distribute pods of the same deployment across different nodes in your Kubernetes cluster.
    - Disabling Default Spreading: You can disable the default pod spreading behavior by setting the Helm value `spread.enabled` to `false`.
    - `spread.maxSkew` Configuration: A new configurable option `spread.maxSkew` has been introduced. It is set to `1` by default. This option defines the maximum allowed difference in the number of pods belonging to this deployment that can exist on any two nodes. A value of `1` encourages a relatively even distribution.
    - Default `whenUnsatisfiable` Behavior: The default spread rule comes with the `spread.whenUnsatisfiable` option set to `ScheduleAnyway`. This means the scheduler will prioritize spreading pods across different nodes. However, if it's not possible to satisfy the spreading constraint (e.g., due to insufficient nodes), the pod will still be scheduled on any available node.
    - Strict Spreading with `whenUnsatisfiable: DoNotSchedule`: If you require a strict spreading policy and want to prevent pods from being scheduled if the spreading constraints cannot be met, you can set `spread.whenUnsatisfiable` to `DoNotSchedule`.
    - Custom `topologySpreadConstraints` Concatenation: If you provide your own custom `topologySpreadConstraints` configuration within the `topologySpreadConstraints` value, these custom rules will be concatenated with the default spread rule generated by the chart. This allows you to add more specific spreading requirements while still benefiting from the default spreading behavior.
  - Version 0.3.10:
    This release introduced new ability to create PVs along side to PVCs, which can be used for example with csi drivers
  - Version 0.3.11:
    This release introduced new ability to
      - Create volume/file mountable config-maps/secrets config items beside standard env variable ones we had. The config/secret items which have prefix "/" in `configs`/`secrets` fields will be treated as mountable configs, check default values.yaml or examples for info how to use this.
      - We have introduced new `configs` field for passing config map data, the old `config` still supported
      - The external secret operator resource default `apiVersion` got changed from "external-secrets.io/v1alpha1" to "external-secrets.io/v1beta1", as `v1alpha1` got deprecated and we already support the new `v1beta1` in k8s/eks setups. It is is still possible to set old version via `externalSecretsApiVersion` config variable
      - the ingress class setting via `ingressClassName` field is default on. Before this it was set via "kubernetes.io/ingress.class" annotation, which is deprecated. It is still possible to switch ingress class setting from `ingressClassName` field back to "kubernetes.io/ingress.class" annotation via config variable `setIngressClassByField: false`
