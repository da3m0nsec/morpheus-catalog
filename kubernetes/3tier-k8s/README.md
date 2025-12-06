# 3-Tier Application on Kubernetes

Complete 3-tier web application deployment on Kubernetes with web, application, and database tiers.

## Architecture

```
Internet → Ingress → Web (nginx) → App (Tomcat) → Database (PostgreSQL)
```

## Components

- **Web Tier**: nginx (3 replicas)
- **App Tier**: Tomcat (2 replicas)
- **Database Tier**: PostgreSQL StatefulSet (1 replica)
- Services: ClusterIP for internal, LoadBalancer for external
- ConfigMaps: nginx config, app config
- Secrets: database credentials
- PersistentVolume: database storage

## Quick Deploy

```bash
kubectl apply -f namespace.yaml
kubectl apply -f secrets.yaml
kubectl apply -f configmaps.yaml
kubectl apply -f database/
kubectl apply -f application/
kubectl apply -f web/
kubectl apply -f ingress.yaml
```

## Access

```bash
kubectl get svc -n 3tier-app
```

See individual YAML files for detailed configuration.
