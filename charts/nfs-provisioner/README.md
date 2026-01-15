# nfs-provisioner
This Helm chart deploys an NFS Provisioner on a Kubernetes cluster. The NFS Provisioner enables dynamic provisioning of Persistent Volumes using an existing NFS server.

## Installation
```
helm repo add dasmeta https://dasmeta.github.io/helm/
helm install nfs-provisioner dasmeta/nfs-provisioner -f custom-values.yaml --version 1.0.0 --create-namespace -n nfs-provisioner
```

!IMPORTANT NOTE!:
 If no options set for persistentVolumeClass field the nfs-provisioner will store volumes data on same node where the provisioner statefulset placed,
and when by some reason provisioner pod getting moved to another node all data in pv will got lost and cluster-local-nfs storage using application pods will fail to start on next deploy as they cant attach volumes.
Only pvc recreate help in that case. So that this way we having imitation of persistent volume by using cluster-local-nfs storage class.

 To prevent this you have to configure the nfs provisioner to use an existing(another) storage class to store its provisioned volumes data there to have persistance.
Its more like the nfc-provisioner and its storage class cluster-local-nfs are acting as an layer over the existing storage class.
Here is how configuration being set:
```file custom-values.yaml
persistentVolumeClass: hcloud-volumes # the existing/other pvc storage class that is actually persistent
persistentVolumeSize: 500Gi # the total size of volume that will be provisioned to be used in nfs provisioner to store its volumes data
```

## Persistent Volumes
When deploying the NFS Provisioner, you can create Persistent Volumes (PVs) dynamically. Here is an example Persistent Volume Claim (PVC) that requests storage from the NFS Provisioner:
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: cluster-local-nfs
```
