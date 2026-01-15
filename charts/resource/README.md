## helm chart allows to create one or multiple kubernetes resources(or CRDs) by passing the resources `apiVersion`, `kind`, `metadata` and `spec` standard resource fields

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
