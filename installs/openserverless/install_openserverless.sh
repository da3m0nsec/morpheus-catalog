#!/bin/bash

# Apache OpenServerless Installation Script
# This script installs Apache OpenServerless on Linux systems

set -e

# Suppress debconf warnings for non-interactive installation
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export NEEDRESTART_SUSPEND=1

echo "========================================="
echo "Apache OpenServerless Installation"
echo "========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    echo "Cannot detect OS version"
    exit 1
fi

echo "Detected OS: $OS $VERSION"

# Configuration
USE_EXISTING_CLUSTER=false
INSTALL_K3S=true
OPS_VERSION="latest"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --use-existing-cluster)
            USE_EXISTING_CLUSTER=true
            INSTALL_K3S=false
            shift
            ;;
        --ops-version)
            OPS_VERSION="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--use-existing-cluster] [--ops-version VERSION]"
            exit 1
            ;;
    esac
done

# Install dependencies based on OS
echo "Installing dependencies..."
case $OS in
    ubuntu|debian)
        apt-get update -qq
        apt-get install -y -qq curl wget git jq
        ;;
    centos|rhel|fedora)
        if command -v dnf &> /dev/null; then
            dnf install -y -q curl wget git jq
        else
            yum install -y -q curl wget git jq
        fi
        ;;
    arch)
        pacman -Sy --noconfirm curl wget git jq
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac
echo "Dependencies installed successfully"

# Install k3s if needed
if [ "$INSTALL_K3S" = true ]; then
    echo "Installing k3s Kubernetes..."

    if ! command -v k3s &> /dev/null; then
        curl -sfL https://get.k3s.io | sh -

        # Wait for k3s to be ready
        echo "Waiting for k3s to be ready..."
        sleep 10

        # Set up kubeconfig for current user
        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

        # Make kubeconfig accessible
        mkdir -p ~/.kube
        cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
        chmod 600 ~/.kube/config

        if [ -n "$SUDO_USER" ]; then
            mkdir -p /home/$SUDO_USER/.kube
            cp /etc/rancher/k3s/k3s.yaml /home/$SUDO_USER/.kube/config
            chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.kube
        fi

        echo "k3s installed successfully"
    else
        echo "k3s is already installed"
    fi
else
    echo "Using existing Kubernetes cluster"

    # Verify kubectl is available
    if ! command -v kubectl &> /dev/null; then
        echo "kubectl not found. Installing kubectl..."

        # Install kubectl
        KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
        curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
        chmod +x kubectl
        mv kubectl /usr/local/bin/
    fi

    # Verify cluster connectivity
    if ! kubectl cluster-info &> /dev/null; then
        echo "Error: Cannot connect to Kubernetes cluster"
        echo "Please ensure KUBECONFIG is set correctly"
        exit 1
    fi
fi

# Install ops CLI
echo "Installing ops CLI..."

if ! command -v ops &> /dev/null; then
    # Download and install ops CLI
    OPS_INSTALL_URL="https://raw.githubusercontent.com/apache/openserverless-cli/main/install.sh"

    echo "Downloading ops CLI..."
    curl -sL $OPS_INSTALL_URL | bash

    # Add to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"

    # Also add to root's PATH if running as sudo
    if [ -n "$SUDO_USER" ]; then
        export PATH="/root/.local/bin:$PATH"
    fi

    # Verify installation
    if command -v ops &> /dev/null; then
        echo "ops CLI installed successfully"
        ops version
    else
        # Try direct path if command not found
        if [ -f "$HOME/.local/bin/ops" ]; then
            echo "ops CLI installed at $HOME/.local/bin/ops"
            $HOME/.local/bin/ops version
            # Create symlink to /usr/local/bin for system-wide access
            ln -sf "$HOME/.local/bin/ops" /usr/local/bin/ops
            echo "Created symlink at /usr/local/bin/ops"
        else
            echo "Error: ops CLI installation failed"
            exit 1
        fi
    fi
else
    echo "ops CLI is already installed"
    ops version
fi

# Ensure ops is in PATH
OPS_CMD="ops"
if ! command -v ops &> /dev/null; then
    if [ -f "/usr/local/bin/ops" ]; then
        OPS_CMD="/usr/local/bin/ops"
    elif [ -f "$HOME/.local/bin/ops" ]; then
        OPS_CMD="$HOME/.local/bin/ops"
    fi
fi

# Install OpenServerless
echo ""
echo "========================================="
echo "Deploying OpenServerless..."
echo "========================================="

# Create namespace
kubectl create namespace openserverless --dry-run=client -o yaml | kubectl apply -f -

# Install OpenServerless using ops CLI
echo "Installing OpenServerless platform..."

# Initialize OpenServerless
$OPS_CMD admin setup

# Wait for deployment
echo "Waiting for OpenServerless components to be ready..."
kubectl wait --for=condition=ready pod -l app=controller -n openserverless --timeout=300s || true

# Get API host
echo ""
echo "Configuring ops CLI..."

# Configure ops for local access
API_HOST=$($OPS_CMD admin apihost)
echo "API Host: $API_HOST"

# Test the installation
echo ""
echo "Testing OpenServerless installation..."
if $OPS_CMD namespace list &> /dev/null; then
    echo "OpenServerless is responding correctly!"
else
    echo "Warning: OpenServerless might not be fully ready. Please wait a few more minutes."
fi

# Print status
echo ""
echo "========================================="
echo "OpenServerless Installation Complete!"
echo "========================================="

# Get cluster info
kubectl get pods -n openserverless

echo ""
echo "OpenServerless has been installed successfully!"
echo ""
echo "API Host: $API_HOST"
echo ""
echo "Next steps:"
echo "  1. Configure ops CLI:"
echo "     ops config"
echo ""
echo "  2. Create your first function:"
echo "     echo 'def main(args): return {\"hello\": \"world\"}' > hello.py"
echo "     ops action create hello hello.py --kind python:3.11"
echo ""
echo "  3. Invoke the function:"
echo "     ops action invoke hello --result"
echo ""
echo "  4. Create an API endpoint:"
echo "     ops api create /hello GET hello"
echo ""
echo "  5. Test the API:"
echo "     curl \"\${API_HOST}/api/v1/web/default/hello\""
echo ""
echo "Documentation: https://openserverless.apache.org/docs/"
echo ""
echo "Kubernetes cluster:"
if [ "$INSTALL_K3S" = true ]; then
    echo "  k3s installed at: /etc/rancher/k3s/k3s.yaml"
    echo "  kubectl config: ~/.kube/config"
fi
echo ""
echo "Useful commands:"
echo "  ops action list           # List all actions"
echo "  ops namespace list        # List namespaces"
echo "  ops activation logs --last # View recent logs"
echo "  kubectl get pods -n openserverless  # Check pods"
echo ""
