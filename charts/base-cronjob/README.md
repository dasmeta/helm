# How to

## Easy Howto
Easiest option to deploy cronjob is:
```bash
helm repo add dasmeta https://dasmeta.github.io/helm/
helm upgrade --install my-cronjob dasmeta/base-cronjob \
  --set jobs[0].name=my-cronjob \
  --set jobs[0].image.repository=my-cronjob \
  --set jobs[0].schedule="* * * * *"
```

## Via values file
Values can be supplied via values.yaml.
```yaml
jobs:
  - name: cronjob1
    schedule: "0 * * * *"
    image:
      repository: my-cronjob
```

```bash
helm repo add dasmeta https://dasmeta.github.io/helm/
helm upgrade --install my-cronjob dasmeta/base-cronjob -f path/to/values.yaml
```

## As sub-chart
Alternatively base chart can be used as sub-chart.

```
dependencies:
  - name: base
    version: 0.1.36
    repository: https://dasmeta.github.io/helm
```

## Resources
Some resources are created only when you specify them.
For example, set this to escape from creating an empty ConfigMap resource:
```
config:
  enabled: false
```
Specify this to create ServiceAccount resource:
```
serviceAccount:
  create: true
```
Set this to have PVCs for a job:
```
storage:
  - persistentVolumeClaimName: pvc-job1-storage1
    keepPvc: true
    accessModes:
      - ReadWriteOnce
    volumeMode: Filesystem
    requestedSize: 5Gi
    className: standard
    enableDataSource: false
  - persistentVolumeClaimName: pvc-job1-storage2
    keepPvc: false
    accessModes:
      - ReadWriteMany
    volumeMode: Filesystem
    requestedSize: 10Gi
    className: standard
    enableDataSource: true
```