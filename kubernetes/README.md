# Kubernetes Deployment Examples

Complete Kubernetes deployment examples in YAML format for HPE Morpheus integration and Kubernetes orchestration demonstrations.

## Overview

This directory contains production-ready Kubernetes manifests organized by deployment pattern. Each example demonstrates different aspects of Kubernetes and can be deployed via:
- **kubectl** - Direct deployment to Kubernetes cluster
- **Morpheus Kubernetes Integration** - Automated deployment through Morpheus
- **Helm Charts** - Package management (where applicable)
- **GitOps** - ArgoCD/Flux integration

## Repository Structure

```
kubernetes/
├── simple-webapp/        # Simple web application deployment
├── 3tier-k8s/            # 3-tier application on Kubernetes
├── microservices-k8s/    # Microservices architecture
├── monitoring-stack/     # Prometheus, Grafana monitoring
├── stateful-apps/        # Stateful applications (databases)
└── README.md                # This file
```

## Deployment Examples

### 1. [Simple Web Application](./simple-webapp/)
**Complexity**: ⭐ Basic | **Components**: 2

Simple nginx web application with LoadBalancer service.

**Resources**:
- 1 Deployment (nginx)
- 1 Service (LoadBalancer)
- 1 ConfigMap (nginx config)

**Use Case**: Getting started, basic web hosting

---

### 2. [3-Tier Application](./3tier-k8s/)
**Complexity**: ⭐⭐⭐ Intermediate | **Components**: 6+

Classic 3-tier architecture on Kubernetes.

**Resources**:
- Frontend: nginx Deployment + Service
- Backend: Tomcat Deployment + Service
- Database: PostgreSQL StatefulSet + Service
- ConfigMaps, Secrets, PersistentVolumes

**Use Case**: Traditional web applications on Kubernetes

---

### 3. [Microservices Architecture](./microservices-k8s/)
**Complexity**: ⭐⭐⭐⭐ Advanced | **Components**: 12+

Modern microservices platform with service mesh capabilities.

**Resources**:
- API Gateway
- Multiple Microservices (User, Product, Order)
- MongoDB, Redis, RabbitMQ
- Ingress Controller
- Service Mesh (optional)

**Use Case**: Cloud-native microservices

---

### 4. [Monitoring Stack](./monitoring-stack/)
**Complexity**: ⭐⭐⭐ Intermediate | **Components**: 8+

Complete observability platform for Kubernetes.

**Resources**:
- Prometheus Operator
- Grafana
- AlertManager
- Node Exporter DaemonSet
- ServiceMonitors

**Use Case**: Cluster and application monitoring

---

### 5. [Stateful Applications](./stateful-apps/)
**Complexity**: ⭐⭐⭐ Intermediate | **Components**: 6+

Databases and stateful workloads on Kubernetes.

**Resources**:
- PostgreSQL StatefulSet
- MongoDB StatefulSet
- Redis Cluster
- PersistentVolumeClaims
- Backup Jobs

**Use Case**: Running databases on Kubernetes

---

## Prerequisites

### Kubernetes Cluster
- Kubernetes 1.24+ recommended
- kubectl configured and connected
- Sufficient resources (CPU, memory, storage)

### Storage
- StorageClass configured (default or custom)
- PersistentVolume provisioner (for stateful apps)

### Networking
- Ingress Controller (nginx, Traefik, etc.)
- LoadBalancer support or NodePort access
- DNS resolution configured

### For Morpheus Integration
- Morpheus appliance with Kubernetes integration
- Kubernetes cluster added as cloud in Morpheus
- Appropriate RBAC permissions

## Quick Start

### Using kubectl

```bash
# Clone the repository
git clone <repository-url>
cd morpheus-catalog/kubernetes

# Choose a deployment
cd simple-webapp

# Review the manifests
ls -la

# Create namespace
kubectl create namespace demo

# Apply manifests
kubectl apply -f . -n demo

# Check status
kubectl get all -n demo

# Access the application
kubectl get svc -n demo
```

### Using Morpheus

1. **Navigate to**: Library → Specs
2. **Add Spec**: Create new Kubernetes Spec
3. **Paste YAML**: Copy manifests from examples
4. **Save**: Name and tag appropriately
5. **Deploy**: Provisioning → Containers → Add Container
6. **Select Spec**: Choose your saved spec
7. **Deploy**: Fill parameters and provision

## Common Kubernetes Resources

### Workload Resources

| Resource | Purpose | Use Case |
|----------|---------|----------|
| **Deployment** | Stateless applications | Web servers, APIs |
| **StatefulSet** | Stateful applications | Databases, queues |
| **DaemonSet** | One pod per node | Monitoring agents, log collectors |
| **Job** | Run-to-completion | Batch processing, migrations |
| **CronJob** | Scheduled jobs | Backups, cleanup tasks |

### Service Resources

| Resource | Purpose | Use Case |
|----------|---------|----------|
| **Service (ClusterIP)** | Internal communication | Service-to-service |
| **Service (NodePort)** | External access via node | Development, testing |
| **Service (LoadBalancer)** | External load balancer | Production external access |
| **Ingress** | HTTP(S) routing | Multi-service routing |

### Configuration Resources

| Resource | Purpose | Use Case |
|----------|---------|----------|
| **ConfigMap** | Non-sensitive config | App configuration, scripts |
| **Secret** | Sensitive data | Passwords, API keys, certificates |

### Storage Resources

| Resource | Purpose | Use Case |
|----------|---------|----------|
| **PersistentVolume** | Storage definition | Pre-provisioned storage |
| **PersistentVolumeClaim** | Storage request | Dynamic provisioning |
| **StorageClass** | Storage types | SSD, HDD, NFS classes |

## Deployment Patterns

### Rolling Updates
```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

### Blue-Green Deployment
- Deploy new version alongside old
- Switch Service selector to new version
- Remove old deployment

### Canary Deployment
- Deploy small percentage to new version
- Monitor metrics
- Gradually increase traffic

### A/B Testing
- Deploy multiple versions
- Route traffic based on headers/rules
- Use Ingress or Service Mesh

## Resource Management

### Resource Requests and Limits

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

### Horizontal Pod Autoscaling

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Security Best Practices

### Pod Security
- Use non-root users
- Read-only root filesystem
- Drop unnecessary capabilities
- Use security contexts

### Network Policies
- Restrict pod-to-pod communication
- Allow only necessary ingress/egress
- Default deny policies

### RBAC
- Principle of least privilege
- Service accounts for applications
- Role-based access control

### Secrets Management
- Use Kubernetes Secrets or external vault
- Encrypt secrets at rest
- Rotate credentials regularly

## Monitoring and Logging

### Prometheus Metrics
- Expose /metrics endpoint
- Use ServiceMonitor for scraping
- Define alert rules

### Logging
- Container logs to stdout/stderr
- Use log aggregation (ELK, Loki)
- Structured logging (JSON)

### Health Checks

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Morpheus Integration

### Instance Types
- Create Kubernetes Instance Types in Morpheus
- Map to Kubernetes Specs
- Define resource plans

### App Blueprints
- Multi-container applications
- Dependencies and ordering
- Environment-specific configs

### Automation
- Post-provision workflows
- Health checks validation
- Integration with CI/CD

### Governance
- Quota management
- Cost tracking per namespace
- Policy enforcement
- Approval workflows

## Troubleshooting

### Common Issues

**Pods not starting**:
```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

**Service not accessible**:
```bash
kubectl get svc -n <namespace>
kubectl get endpoints -n <namespace>
```

**Storage issues**:
```bash
kubectl get pv
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc-name> -n <namespace>
```

### Useful Commands

```bash
# Get all resources in namespace
kubectl get all -n <namespace>

# Describe resource
kubectl describe <resource-type> <name> -n <namespace>

# View logs
kubectl logs <pod-name> -n <namespace> -f

# Execute command in pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash

# Port forward
kubectl port-forward <pod-name> 8080:80 -n <namespace>

# Get events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

## Best Practices

### Namespace Organization
- Separate environments (dev, staging, prod)
- Resource quotas per namespace
- Network policies per namespace

### Labels and Selectors
- Consistent labeling strategy
- app, version, component labels
- Use for organization and selection

### ConfigMaps and Secrets
- Externalize configuration
- Version control manifests, not secrets
- Use sealed secrets or external vaults

### Resource Limits
- Always set requests and limits
- Prevent resource starvation
- Enable autoscaling

### Health Checks
- Implement liveness probes
- Implement readiness probes
- Graceful shutdown handling

## Example Workflows

### Deploy Application

```bash
# Create namespace
kubectl create namespace myapp

# Apply configs
kubectl apply -f configmap.yaml -n myapp
kubectl apply -f secret.yaml -n myapp

# Deploy database
kubectl apply -f database-statefulset.yaml -n myapp
kubectl apply -f database-service.yaml -n myapp

# Wait for database
kubectl wait --for=condition=ready pod -l app=database -n myapp --timeout=300s

# Deploy application
kubectl apply -f app-deployment.yaml -n myapp
kubectl apply -f app-service.yaml -n myapp

# Expose with Ingress
kubectl apply -f ingress.yaml -n myapp
```

### Update Application

```bash
# Update image
kubectl set image deployment/myapp myapp=myapp:v2 -n myapp

# Check rollout status
kubectl rollout status deployment/myapp -n myapp

# Rollback if needed
kubectl rollout undo deployment/myapp -n myapp
```

### Scale Application

```bash
# Manual scaling
kubectl scale deployment/myapp --replicas=5 -n myapp

# Enable autoscaling
kubectl autoscale deployment myapp --cpu-percent=70 --min=2 --max=10 -n myapp
```

## Integration with CI/CD

### GitOps Approach
- Store manifests in Git
- Use ArgoCD or Flux
- Automatic synchronization
- Audit trail

### CI/CD Pipeline
1. Build container image
2. Push to registry
3. Update manifest with new tag
4. Apply to cluster
5. Verify deployment

## Next Steps

- Review individual deployment examples
- Test in development cluster
- Customize for your environment
- Import into Morpheus
- Set up monitoring and logging
- Implement CI/CD pipeline

## Additional Resources

- **Kubernetes Documentation**: https://kubernetes.io/docs/
- **Kubectl Cheat Sheet**: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- **Morpheus K8s Integration**: https://docs.morpheusdata.com/
- **Helm Charts**: https://helm.sh/
- **CNCF Landscape**: https://landscape.cncf.io/

---

For detailed examples and specific configurations, explore the individual deployment directories.
