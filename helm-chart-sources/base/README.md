# How to
Chart.yaml
```
apiVersion: v2
name: my-application
description: My application service description
type: application
version: 0.1.0
appVersion: "0.1.0"

dependencies: # A list of the chart requirements (optional)
  - name: base
    version: 1.2.3
    repository: (https://dasmeta.github.io/charts
    alias: app
```

values.yaml
```
app:
  image: my-app-docker-image
  tag: 1.2.3
```

Run
```
helm upgrade --install my-app .
```
