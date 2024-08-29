# nfs-provisioner
This Helm chart deploys an NFS Provisioner on a Kubernetes cluster. The NFS Provisioner enables dynamic provisioning of Persistent Volumes using an existing NFS server.

## Installation
```
helm repo add dasmeta https://dasmeta.github.io/helm/
helm install nfs-provisioner dasmeta/nfs-provisioner -f custom-values.yaml --version 1.0.0 --create-namespace -n nfs-provisioner
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

