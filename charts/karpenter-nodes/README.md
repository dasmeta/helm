# This helm chart allows to create karpenter EC2NodeClass and NodePool resources check here for more details https://karpenter.sh/docs/concepts/ , it also creates FlowSchema resources(in case if karpenter was created not in kube-system, in case of karpenter installed on kube-system the kubernetes provides those resource automatically) for karpenter to access kubernetes api server with priority

## to install the chart use the command
```sh
helm upgrade --install -n karpenter karpenter-nodes dasmeta/karpenter-nodes -f path-of-values.yaml
```

## example of configs to create karpenter nodes resources
```yaml
# EC2NodeClass object configs, to enable AWS specific settings, each NodePool must reference an NodeClass, for more info look https://karpenter.sh/docs/concepts/nodeclasses/
ec2NodeClasses:
  my-node-class:
    amiFamily: AL2
    amiSelectorTerms: # aws ami which will be used for nodes
      - id: ami-0e7df911d76024f90
    role: <eks-node-iam-role-name> # iam identity role name nodes should assume (optional)
    securityGroupSelectorTerms: # vpc security group nodes should get, usually this is same group used/created for eks standard nodes
    - tags:
        karpenter.sh/discovery: test-cluster-with-karpenter
    subnetSelectorTerms: # the vpc subnets used for nodes, usually this is same list that used for eks
    - id: subnet-<subnet-uid-1>
    - id: subnet-<subnet-uid-2>
    - id: subnet-<subnet-uid-3>
# NodePool to create, this is map of <pool-name>:<pool-spec-object>, for more info look https://karpenter.sh/docs/concepts/nodepools/
nodePools:
  my-node-pool:
    template:
      spec:
        expireAfter: Never
        nodeClassRef:
          group: karpenter.k8s.aws
          kind: EC2NodeClass
          name: my-node-class # this is name of EC2NodeClass, an node-class can be referenced by multiple node-pools
        requirements:
        - key: karpenter.k8s.aws/instance-cpu
          operator: Lt
          values:
          - "5"
        - key: karpenter.k8s.aws/instance-cpu
          operator: Gt
          values:
          - "1"
        - key: karpenter.k8s.aws/instance-memory
          operator: Lt
          values:
          - "90000"
        - key: karpenter.k8s.aws/instance-memory
          operator: Gt
          values:
          - "1000"
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values:
          - "2"
        - key: kubernetes.io/arch
          operator: In
          values:
          - amd64
        - key: karpenter.sh/capacity-type
          operator: In
          values:
          - spot
          - on-demand
    disruption:
      budgets:
      - nodes: 10%
      consolidateAfter: 1m
      consolidationPolicy: WhenEmptyOrUnderutilized
    limits:
      cpu: 10
    weight: 1
```
