#!/bin/bash

# Docker Installation Script
# This script installs Docker Engine on Linux systems

set -e

echo "========================================="
echo "Docker Installation Script"
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

# Remove old Docker versions
echo "Removing old Docker versions if present..."
case $OS in
    ubuntu|debian)
        apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
        ;;
    centos|rhel|fedora)
        if command -v dnf &> /dev/null; then
            dnf remove -y docker docker-client docker-client-latest docker-common docker-latest \
                docker-latest-logrotate docker-logrotate docker-engine 2>/dev/null || true
        else
            yum remove -y docker docker-client docker-client-latest docker-common docker-latest \
                docker-latest-logrotate docker-logrotate docker-engine 2>/dev/null || true
        fi
        ;;
esac

# Install Docker based on OS
case $OS in
    ubuntu|debian)
        echo "Installing Docker on Debian/Ubuntu..."

        # Install prerequisites
        apt-get update
        apt-get install -y ca-certificates curl gnupg lsb-release

        # Add Docker's official GPG key
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/$OS/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg

        # Set up the repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
          $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker Engine
        apt-get update
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        ;;

    centos|rhel|fedora)
        echo "Installing Docker on RHEL/CentOS/Fedora..."

        # Install prerequisites
        if command -v dnf &> /dev/null; then
            dnf install -y yum-utils
        else
            yum install -y yum-utils
        fi

        # Add Docker repository
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

        # Install Docker Engine
        if command -v dnf &> /dev/null; then
            dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        else
            yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        fi
        ;;

    arch)
        echo "Installing Docker on Arch Linux..."
        pacman -Sy --noconfirm docker docker-compose
        ;;

    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Start and enable Docker service
echo "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add current user to docker group (if not root)
if [ -n "$SUDO_USER" ]; then
    echo "Adding user $SUDO_USER to docker group..."
    usermod -aG docker $SUDO_USER
    echo "Note: User $SUDO_USER will need to log out and back in for group changes to take effect"
fi

# Test Docker installation
echo "Testing Docker installation..."
docker run hello-world

# Check service status
echo ""
echo "========================================="
echo "Docker Installation Complete!"
echo "========================================="
systemctl status docker --no-pager

echo ""
echo "Docker has been installed successfully!"
echo ""
echo "Docker version:"
docker --version
echo ""
echo "Docker Compose version:"
docker compose version
echo ""
echo "To use Docker without sudo, log out and back in (if user was added to docker group)"
echo ""
echo "Basic commands:"
echo "  docker ps          - List running containers"
echo "  docker images      - List images"
echo "  docker run IMAGE   - Run a container"
echo "  docker compose up  - Start services from docker-compose.yml"
