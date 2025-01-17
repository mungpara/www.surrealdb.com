apiVersion: pingcap.com/v1alpha1
kind: TidbCluster
metadata:
  name: sdb-datastore
spec:
  version: v6.5.0
  timezone: UTC
  configUpdateStrategy: RollingUpdate
  pvReclaimPolicy: Delete
  enableDynamicConfiguration: true
  schedulerName: default-scheduler
  topologySpreadConstraints:
  - topologyKey: topology.kubernetes.io/zone
  helper:
    image: alpine:3.16.0
  pd:
    baseImage: pingcap/pd
    maxFailoverCount: 0
    replicas: 3
    storageClassName: premium-rwo
    requests:
      cpu: 500m
      storage: 10Gi
      memory: 1Gi
    config: |
      [dashboard]
        internal-proxy = true
      [replication]
        location-labels = ["topology.kubernetes.io/zone", "kubernetes.io/hostname"]
        max-replicas = 3
    nodeSelector:
      dedicated: pd
    tolerations:
    - effect: NoSchedule
      key: dedicated
      operator: Equal
      value: pd
    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
            - key: app.kubernetes.io/component
              operator: In
              values:
              - pd
          topologyKey: kubernetes.io/hostname
  tikv:
    baseImage: pingcap/tikv
    maxFailoverCount: 0
    replicas: 3
    storageClassName: premium-rwo
    requests:
      cpu: 1
      storage: 10Gi
      memory: 2Gi
    config: {}
    nodeSelector:
      dedicated: tikv
    tolerations:
    - effect: NoSchedule
      key: dedicated
      operator: Equal
      value: tikv
    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
            - key: app.kubernetes.io/component
              operator: In
              values:
              - tikv
          topologyKey: kubernetes.io/hostname
  tidb:
    replicas: 0
