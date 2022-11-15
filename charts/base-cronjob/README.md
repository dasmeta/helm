# How to

```
dependencies:
  - name: base-cronjob
    version: 0.1.0
    repository: https://dasmeta.github.io/helm
```

```bash
$ helm dependency update
$ helm install my-app .
```

## Introduction

This chart provides a base cronjob template helpers which can be used to develop new charts using [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.21+
- Helm 3.7.1

## Default Values

```
nameOverride: ""
fullnameOverride: ""

image:
  registry: docker.io
  repository: busybox
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: latest

imagePullSecrets: []

secrets: {}

customConfigMap:

configMaps: {}

env: []

jobs: {}
#  test:
#    schedule: "*/5 * * * *"
#    command:
#      - /bin/sh
#      - -c
#    args:
#      - echo "foo"; ps fauxwww
#    image:
#      repository: alpine
#    # see https://github.com/kubernetes/kubernetes/issues/74848#issuecomment-475178355
#    # restartPolicy: Never
#    # startingDeadlineSeconds: 60
#    # activeDeadlineSeconds: 60
#    # backoffLimit: 3
#    # completions: 3
#    # parallelism: 1
#    # ttlSecondsAfterFinished: 60
#    # suspend: false

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}

podSecurityContext: {}

securityContext: {}

resources: {}
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
#   memory: 128Mi

nodeSelector: {}

tolerations: []

affinity: {}
```

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
    version: 0.1.32
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
    version: 0.1.32
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
  - name: base-cronjob
    version: 0.1.32
    repository: https://dasmeta.github.io/helm
```
