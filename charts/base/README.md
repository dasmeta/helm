# Problems
If you want your chart to have the name `my-app-base` you have to specify it in Chart.yaml file by passing it to `alias`. After everything has to be defined under the alias name(in this case under `my-app-base`) in your values.yaml file. Otherwise, it will get the name `base`. It's a problem that has no dynamic solution in helm. The same problem is with the version and appVersion. Your parent chart will receive `base`'s version if you do not change them by these 2 variables: `version`, `appVersion`. None of these is a mandatory value, so without them, you will have no problem in the process of running the chart.
Here are 2 examples about this:
# How to

## Example 1(alias is not specified, name, version and appVersion are not overridden by parent chart)
In this case, labels will be like this:
 `helm.sh/chart: base-0.1.15`
 `app.kubernetes.io/name: base`
 `app.kubernetes.io/version: 0.1.15`

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
    version: 0.1.15
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

## Example 2(alias is specified/or name is overriden, also version and appVersion are overridden by parent chart)
Now if you prefer to change your chart's name and version, you can do it by the alias variable(passing a name to it in Chart.yaml) or you can override the `name` in values.yaml file. The result will be the same. About `version` and `appVersion`, they have to be changed in values.yaml.
The same labels, given above, now will be:
 `helm.sh/chart: my-app-base-0.1.0`
 `app.kubernetes.io/name: my-app-base`
 `app.kubernetes.io/version: 0.1.0`

This is with the alias name.

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
    version: 0.1.15
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

This is by overridding the `name`.

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
    version: 0.1.15
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

# Secret Store
This will create a Secret Store. In our templates AWS provider is used for this component. If you want to create Secret Store with other providers, you have to add a new file in your chart. Maybe we'll find a better solution later. 
For this case, you just need to create a k8s secret with 2 properties, and their keys have to be `access-key` and `secret-access-key`, first of these will be your access key for AWS, and second one will be the secret access key. Then add this part in your values.yaml file.
values.yaml
```
my-app-base:
  ...
  secretStore:
    role: arn:aws:iam::1234567890:role/your-role
    secretName: your-secret

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
