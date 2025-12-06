#!/bin/bash

# MongoDB Installation Script
# This script installs MongoDB on Linux systems

set -e

echo "========================================="
echo "MongoDB Installation Script"
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

# Install MongoDB based on OS
case $OS in
    ubuntu|debian)
        echo "Installing MongoDB on Debian/Ubuntu..."

        # Import MongoDB public GPG key
        apt-get install -y gnupg curl
        curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
            gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

        # Add MongoDB repository
        if [ "$OS" = "ubuntu" ]; then
            echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
                tee /etc/apt/sources.list.d/mongodb-org-7.0.list
        else
            echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/7.0 main" | \
                tee /etc/apt/sources.list.d/mongodb-org-7.0.list
        fi

        # Install MongoDB packages
        apt-get update
        apt-get install -y mongodb-org
        ;;

    centos|rhel|fedora)
        echo "Installing MongoDB on RHEL/CentOS/Fedora..."

        # Create repository file
        cat > /etc/yum.repos.d/mongodb-org-7.0.repo <<EOF
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-7.0.asc
EOF

        # Install MongoDB
        if command -v dnf &> /dev/null; then
            dnf install -y mongodb-org
        else
            yum install -y mongodb-org
        fi
        ;;

    arch)
        echo "Installing MongoDB on Arch Linux..."
        pacman -Sy --noconfirm mongodb-bin mongodb-tools-bin
        ;;

    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Start and enable MongoDB service
echo "Starting MongoDB service..."
systemctl start mongod
systemctl enable mongod

# Check service status
echo ""
echo "========================================="
echo "MongoDB Installation Complete!"
echo "========================================="
systemctl status mongod --no-pager

echo ""
echo "MongoDB has been installed successfully!"
echo "Default port: 27017"
echo "Default bind address: 127.0.0.1"
echo ""
echo "To connect to MongoDB:"
echo "  mongosh"
echo ""
echo "Configuration file: /etc/mongod.conf"
echo "Data directory: /var/lib/mongodb"
echo "Log directory: /var/log/mongodb"
