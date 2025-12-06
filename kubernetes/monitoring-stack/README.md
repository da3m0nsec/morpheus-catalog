# Monitoring Stack on Kubernetes

Prometheus, Grafana, and exporters for complete observability.

## Components

- Prometheus (metrics collection)
- Grafana (visualization)
- Node Exporter (DaemonSet)
- AlertManager (optional)

## Deploy

```bash
kubectl apply -f all-in-one.yaml
```

## Access

```bash
# Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Grafana  
kubectl port-forward -n monitoring svc/grafana 3000:3000
# Default: admin/admin
```
