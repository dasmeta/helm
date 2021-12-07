# Problems
If you want your chart to have name `my-app-base` you have to specify it in values.yaml file. Otherwise it will get name `base`. It's a problem which has no solution in helm. Here are 2 examples about this:
# How to

## Example 1(chart's name will be base)
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
    version: 0.1.11
    repository: https://dasmeta.github.io/helm
    alias: my-app-base
```

values.yaml
These are mandatory values you should provide.
```
my-app-base:
  image: 
    repository: docker-image
    tag: 1.2.3
```

## Example 2(chart's name will be my-app-base)
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
    version: 0.1.11
    repository: https://dasmeta.github.io/helm
    alias: my-app-base
```

values.yaml
These are mandatory values you should provide and also custom value for `name`.
```
my-app-base:
  name: my-app-base
  image: 
    repository: docker-image
    tag: 1.2.3
```

# External secrets
This will produce external secrets which will ask secrets from store my-app-production.
Values in Secret Manager should be put in my-product/production/my-app matching secret1, secret2, secret2.
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

# Volumes
```
my-app-base:
  ...
  deployment:
    volumes:
    - name: test-volume
      persistentVolumeClaim:
        claimName:
```

# Health Checks
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



Run
```
helm dependency update
helm upgrade --install my-app .
```
