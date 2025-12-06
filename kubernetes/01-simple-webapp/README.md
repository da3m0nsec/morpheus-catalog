# Simple Web Application on Kubernetes

Basic nginx web application deployment demonstrating fundamental Kubernetes concepts.

## Architecture

```
Internet
   │
   ▼
[LoadBalancer Service]
   │
   ▼
[nginx Pods (3 replicas)]
   │
   ▼
[ConfigMap: nginx.conf]
```

## Components

### 1. Namespace
- **File**: `namespace.yaml`
- **Purpose**: Isolated environment for the application

### 2. ConfigMap
- **File**: `configmap.yaml`
- **Purpose**: nginx configuration
- **Contains**: Custom nginx.conf

### 3. Deployment
- **File**: `deployment.yaml`
- **Purpose**: nginx web server
- **Replicas**: 3
- **Image**: nginx:1.25-alpine
- **Resources**: 100m CPU, 128Mi memory

### 4. Service
- **File**: `service.yaml`
- **Type**: LoadBalancer
- **Port**: 80
- **Purpose**: Expose application externally

### 5. Ingress (Optional)
- **File**: `ingress.yaml`
- **Purpose**: HTTP routing with domain name
- **Controller**: nginx-ingress

## Quick Start

### Deploy with kubectl

```bash
# Create namespace and deploy all resources
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Optional: Deploy ingress
kubectl apply -f ingress.yaml

# Check deployment status
kubectl get all -n simple-webapp

# Get service external IP
kubectl get svc webapp-service -n simple-webapp

# Watch pods
kubectl get pods -n simple-webapp -w
```

### Access the Application

```bash
# Get the LoadBalancer IP
export SERVICE_IP=$(kubectl get svc webapp-service -n simple-webapp -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Access the application
curl http://$SERVICE_IP

# Or open in browser
echo "http://$SERVICE_IP"
```

## Scaling

### Manual Scaling

```bash
# Scale to 5 replicas
kubectl scale deployment webapp-deployment -n simple-webapp --replicas=5

# Verify scaling
kubectl get pods -n simple-webapp
```

### Horizontal Pod Autoscaler

```bash
# Create HPA (requires metrics-server)
kubectl autoscale deployment webapp-deployment -n simple-webapp \
  --cpu-percent=70 \
  --min=3 \
  --max=10

# Check HPA status
kubectl get hpa -n simple-webapp
```

## Updates and Rollbacks

### Rolling Update

```bash
# Update to new nginx version
kubectl set image deployment/webapp-deployment \
  nginx=nginx:1.26-alpine \
  -n simple-webapp

# Watch rollout
kubectl rollout status deployment/webapp-deployment -n simple-webapp

# Check rollout history
kubectl rollout history deployment/webapp-deployment -n simple-webapp
```

### Rollback

```bash
# Rollback to previous version
kubectl rollout undo deployment/webapp-deployment -n simple-webapp

# Rollback to specific revision
kubectl rollout undo deployment/webapp-deployment -n simple-webapp --to-revision=1
```

## Monitoring

### Check Logs

```bash
# Get logs from all pods
kubectl logs -l app=webapp -n simple-webapp

# Follow logs
kubectl logs -f deployment/webapp-deployment -n simple-webapp

# Get logs from specific pod
kubectl logs <pod-name> -n simple-webapp
```

### Check Resource Usage

```bash
# Get resource usage (requires metrics-server)
kubectl top pods -n simple-webapp
kubectl top nodes
```

### Describe Resources

```bash
# Describe deployment
kubectl describe deployment webapp-deployment -n simple-webapp

# Describe service
kubectl describe svc webapp-service -n simple-webapp

# Describe pods
kubectl describe pods -l app=webapp -n simple-webapp
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n simple-webapp

# Describe problem pod
kubectl describe pod <pod-name> -n simple-webapp

# Check events
kubectl get events -n simple-webapp --sort-by='.lastTimestamp'
```

### Service Not Accessible

```bash
# Check service
kubectl get svc -n simple-webapp

# Check endpoints
kubectl get endpoints webapp-service -n simple-webapp

# Test from within cluster
kubectl run -it --rm debug --image=busybox --restart=Never -n simple-webapp -- sh
# Inside container:
wget -O- http://webapp-service
```

### Common Issues

**LoadBalancer Pending**:
- Cloud provider doesn't support LoadBalancer
- Use NodePort instead or install MetalLB

**ImagePullBackOff**:
- Check image name and tag
- Verify registry access

**CrashLoopBackOff**:
- Check container logs
- Verify configuration

## Customization

### Update HTML Content

Edit `configmap.yaml` to change the served HTML:

```yaml
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head><title>My Custom Page</title></head>
    <body>
      <h1>Custom Content Here</h1>
    </body>
    </html>
```

Apply changes:
```bash
kubectl apply -f configmap.yaml -n simple-webapp
kubectl rollout restart deployment/webapp-deployment -n simple-webapp
```

### Use NodePort Instead of LoadBalancer

Edit `service.yaml`:

```yaml
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080  # Optional: specific node port
```

Access via: `http://<node-ip>:30080`

## Cleanup

```bash
# Delete all resources
kubectl delete -f . -n simple-webapp

# Delete namespace
kubectl delete namespace simple-webapp

# Or delete everything at once
kubectl delete namespace simple-webapp
```

## Morpheus Integration

### Create Instance Type

1. Navigate to Library → Instance Types
2. Create new Instance Type: "Kubernetes - Simple Webapp"
3. Add Kubernetes Spec
4. Paste contents of YAML files
5. Configure inputs:
   - Replica count
   - Image version
   - Resource limits

### Create Catalog Item

1. Navigate to Library → Catalog Items
2. Create from Instance Type
3. Set visibility and permissions
4. Add to appropriate groups

### Deploy via Morpheus

1. Provisioning → Containers
2. Select "Kubernetes - Simple Webapp"
3. Choose cluster
4. Configure options
5. Deploy

## Production Considerations

### High Availability
- Use at least 3 replicas
- Set pod anti-affinity rules
- Deploy across multiple availability zones

### Resource Management
- Set appropriate resource requests/limits
- Enable HPA for traffic spikes
- Monitor resource usage

### Security
- Use read-only root filesystem
- Run as non-root user
- Implement network policies
- Use secrets for sensitive data

### Monitoring
- Deploy Prometheus monitoring
- Set up alerts
- Configure health checks
- Implement logging

## Next Steps

- Add persistent storage for custom content
- Implement SSL/TLS with cert-manager
- Add monitoring with Prometheus
- Implement CI/CD pipeline
- Try [3-Tier Application](../02-3tier-k8s/) for more complex deployment
