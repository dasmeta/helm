## helm chart allows to create one or multiple kubernetes resources(or CRDs) by passing the resources `apiVersion`, `kind`, `metadata` and `spec` standard resource fields

Install: `helm repo add dasmeta https://dasmeta.github.io/helm` then `helm upgrade --install my-resource dasmeta/resource -f values.yaml`. Public values: [values.yaml](./values.yaml). Examples: [examples/resource/](../../examples/resource/). From repo root: `helm template test charts/resource -f examples/resource/single.config.yaml`.

### Key values

| Key | Description | Default / Example |
| --- | ----------- | ----------------- |
| `resource` | Single Kubernetes resource (apiVersion, kind, metadata, spec/data) | example in values.yaml |
| `resources` | Alias for resource; list or single resource definitions | if set, `resource` is ignored; see examples/ |

##  example how resource/resources field value can be in case we have just single object, for more examples check [../../examples/resource](../../examples/resource) folder.
```yaml
# values.yaml
resource:
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: single-config-map
   data:
     some-key: single-config-map-content
```
