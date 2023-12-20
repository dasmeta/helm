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
