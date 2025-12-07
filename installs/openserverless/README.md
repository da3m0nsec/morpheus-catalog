# Apache OpenServerless Installation and Configuration

This directory contains scripts and documentation for installing and configuring Apache OpenServerless.

## Overview

Apache OpenServerless is a complete cloud platform that enables building cloud applications using serverless technologies. It provides:
- **Serverless Functions** (FaaS)
- **API Gateway**
- **Event-driven architecture**
- **Multi-language support** (Python, Node.js, Go, Java, PHP, Ruby, etc.)
- **Built-in storage and databases**

## Contents

- `install_openserverless.sh` - Installation script for Apache OpenServerless

## Installation

Run the installation script:

```bash
bash install_openserverless.sh
```

## Requirements

### System Requirements
- Linux-based operating system (Ubuntu 22.04 LTS recommended)
- Root or sudo privileges
- Minimum 4GB RAM (8GB recommended)
- Minimum 2 CPU cores (4 recommended)
- 20GB available disk space

### Kubernetes Cluster
OpenServerless requires a Kubernetes cluster. The installation script can:
- **Install k3s** (lightweight Kubernetes) automatically
- **Use existing Kubernetes cluster** (k8s, k3s, kind, minikube)

### Prerequisites Installed Automatically
- kubectl
- k3s (if not using existing cluster)
- ops CLI (OpenServerless command-line tool)

## Installation Options

### Option 1: Quick Install with k3s (Recommended)

```bash
# Install OpenServerless with k3s
sudo bash install_openserverless.sh
```

This will:
1. Install k3s Kubernetes
2. Install ops CLI
3. Deploy OpenServerless on k3s
4. Configure API access

### Option 2: Install on Existing Kubernetes

```bash
# Set your kubeconfig
export KUBECONFIG=/path/to/your/kubeconfig

# Install OpenServerless
sudo bash install_openserverless.sh --use-existing-cluster
```

## Post-Installation

### Access the Platform

After installation, you'll have access to:

**OpenServerless API**:
```bash
# Get API endpoint
ops apihost get

# Get authentication token
ops auth whoami
```

**Kubernetes Dashboard** (if installed):
```bash
kubectl proxy
# Access at http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

## Quick Start

### 1. Login to OpenServerless

```bash
# Configure ops CLI
ops config

# Login (if authentication is enabled)
ops login
```

### 2. Create Your First Action (Function)

**Python Example**:
```bash
# Create a Python function
cat > hello.py <<'EOF'
def main(args):
    name = args.get("name", "World")
    return {"message": f"Hello, {name}!"}
EOF

# Deploy the function
ops action create hello hello.py --kind python:3.11

# Invoke the function
ops action invoke hello --result --param name "OpenServerless"
```

**Node.js Example**:
```bash
# Create a Node.js function
cat > hello.js <<'EOF'
function main(params) {
    const name = params.name || 'World';
    return { message: `Hello, ${name}!` };
}
EOF

# Deploy the function
ops action create helloNode hello.js --kind nodejs:18

# Invoke the function
ops action invoke helloNode --result --param name "OpenServerless"
```

### 3. Create an API Endpoint

```bash
# Expose function as HTTP endpoint
ops api create /hello GET hello --response-type json

# Test the API
curl "$(ops apihost get)/api/v1/web/default/hello?name=World"
```

### 4. List Your Actions

```bash
# List all actions
ops action list

# Get action details
ops action get hello
```

## Common Operations

### Managing Actions

```bash
# Create action
ops action create <name> <file> --kind <runtime>

# Update action
ops action update <name> <file>

# Delete action
ops action delete <name>

# Invoke action
ops action invoke <name> --result --param key value

# Get action logs
ops activation logs --last
```

### Managing Packages

```bash
# Create package
ops package create mypackage

# Add action to package
ops action create mypackage/action1 action1.py

# List packages
ops package list

# Get package details
ops package get mypackage
```

### Managing APIs

```bash
# Create API endpoint
ops api create /<path> <method> <action>

# List APIs
ops api list

# Delete API
ops api delete /<path>
```

## Available Runtimes

OpenServerless supports multiple languages:

| Language | Runtime | Version |
|----------|---------|---------|
| Python | python:3.11 | 3.11 |
| Python | python:3.10 | 3.10 |
| Node.js | nodejs:18 | 18.x |
| Node.js | nodejs:20 | 20.x |
| Go | go:1.21 | 1.21 |
| Java | java:17 | OpenJDK 17 |
| PHP | php:8.2 | 8.2 |
| Ruby | ruby:3.2 | 3.2 |
| .NET | dotnet:6 | .NET 6 |

## Configuration

### OpenServerless Configuration File

Location: `~/.ops/config.json`

```json
{
  "apihost": "https://api.openserverless.local",
  "auth": "your-auth-token",
  "namespace": "default"
}
```

### Environment Variables

```bash
# Set API host
export OPS_APIHOST="https://api.openserverless.local"

# Set authentication token
export OPS_AUTH="your-auth-token"

# Set namespace
export OPS_NAMESPACE="default"
```

## Advanced Features

### Sequences (Function Composition)

```bash
# Create a sequence of actions
ops action create mySequence --sequence action1,action2,action3

# Invoke sequence
ops action invoke mySequence --result
```

### Triggers and Rules

```bash
# Create a trigger
ops trigger create myTrigger

# Create a rule to connect trigger to action
ops rule create myRule myTrigger myAction

# Fire the trigger
ops trigger fire myTrigger --param key value
```

### Web Actions

```bash
# Create web action (HTTP accessible)
ops action create hello hello.py --web true

# Access web action
curl "$(ops apihost get)/api/v1/web/default/hello"
```

### Docker Actions

```bash
# Use custom Docker image
ops action create myDockerAction --docker username/imagename:tag
```

## Monitoring and Debugging

### View Activation Logs

```bash
# Get recent activations
ops activation list

# Get specific activation details
ops activation get <activation-id>

# Get activation logs
ops activation logs <activation-id>

# Get last activation logs
ops activation logs --last

# Poll for new activations
ops activation poll
```

### Performance Metrics

```bash
# Get action execution statistics
ops action get hello --summary
```

## Scaling and Performance

### Concurrency Settings

```bash
# Set concurrency limit
ops action update hello --concurrency 100

# Set memory limit
ops action update hello --memory 256

# Set timeout
ops action update hello --timeout 60000
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Deploy to OpenServerless
on: [push]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install ops CLI
        run: |
          curl -sL https://get.openserverless.io | bash
      - name: Deploy functions
        run: |
          ops login --apihost ${{ secrets.OPS_APIHOST }} --auth ${{ secrets.OPS_AUTH }}
          ops action update myfunction function.py
```

## Backup and Restore

### Export Actions

```bash
# Export all actions
ops project export > backup.json

# Import actions
ops project import backup.json
```

## Uninstallation

```bash
# Remove OpenServerless from Kubernetes
ops admin uninstall

# Remove k3s (if installed by script)
/usr/local/bin/k3s-uninstall.sh

# Remove ops CLI
sudo rm /usr/local/bin/ops
```

## Troubleshooting

### Check Cluster Status

```bash
# Check Kubernetes nodes
kubectl get nodes

# Check OpenServerless pods
kubectl get pods -n openserverless

# Check OpenServerless services
kubectl get svc -n openserverless
```

### Common Issues

**API Host Not Accessible**:
```bash
# Check service status
kubectl get svc -n openserverless
kubectl describe svc controller -n openserverless
```

**Action Execution Fails**:
```bash
# Check activation logs
ops activation logs --last

# Check action details
ops action get <action-name>
```

**CLI Not Working**:
```bash
# Verify ops configuration
ops config

# Test connection
ops namespace list
```

## Security Best Practices

- Use authentication and authorization
- Limit function execution time (timeouts)
- Set appropriate memory limits
- Use namespaces for isolation
- Rotate authentication tokens regularly
- Enable TLS/SSL for API access
- Review function logs regularly
- Implement rate limiting

## Resources

- **Official Documentation**: https://openserverless.apache.org/docs/
- **GitHub Repository**: https://github.com/apache/openserverless
- **Tutorials**: https://openserverless.apache.org/docs/tutorial/
- **API Reference**: https://openserverless.apache.org/docs/reference/
- **Community**: Apache OpenServerless Slack/Discord

## Next Steps

- Explore [Serverless Application Example](../../deployments/serverless-app/) for a complete application
- Try different runtimes and languages
- Build event-driven architectures
- Integrate with external services
- Set up CI/CD pipelines
- Implement monitoring and alerting

## Support

For issues and questions:
- Check the official documentation
- Review GitHub issues
- Ask in community channels
- Consult deployment examples in this repository
