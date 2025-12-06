# Stateful Applications on Kubernetes

Examples of running stateful applications (databases) on Kubernetes using StatefulSets.

## Components

- PostgreSQL StatefulSet
- MongoDB StatefulSet  
- Redis Cluster
- PersistentVolumeClaims

## Deploy

```bash
kubectl apply -f all-in-one.yaml
```

## Features

- Persistent storage
- Ordered deployment
- Stable network identities
- Data persistence across pod restarts
