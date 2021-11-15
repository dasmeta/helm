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
    version: 0.1.14
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

External secrets
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
This will produce externals ecrets which will ask secrets from store my-app-production.
Values in Secret Manager should be put in my-product/production/my-app matching secret1, secret2, secret2.

Run
```
helm upgrade --install my-app .
```
