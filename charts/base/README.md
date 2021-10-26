# How to
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
    version: 0.1.7
    repository: https://dasmeta.github.io/helm
    alias: my-app-base
```

values.yaml
```
my-app-base:
  image: 
    repository: docker-image
    tag: 1.2.3
```

Run
```
helm upgrade --install my-app .
```
