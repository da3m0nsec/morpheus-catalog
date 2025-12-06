#!/bin/bash

# Redis Installation Script
# This script installs Redis on Linux systems

set -e

echo "========================================="
echo "Redis Installation Script"
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

# Install Redis based on OS
case $OS in
    ubuntu|debian)
        echo "Installing Redis on Debian/Ubuntu..."

        # Update package list
        apt-get update

        # Install Redis
        apt-get install -y redis-server redis-tools

        # Configure Redis to run as a service
        systemctl enable redis-server
        systemctl start redis-server

        SERVICE_NAME="redis-server"
        CONF_FILE="/etc/redis/redis.conf"
        ;;

    centos|rhel|fedora)
        echo "Installing Redis on RHEL/CentOS/Fedora..."

        # Enable EPEL repository for CentOS/RHEL
        if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
            if command -v dnf &> /dev/null; then
                dnf install -y epel-release
                dnf install -y redis
            else
                yum install -y epel-release
                yum install -y redis
            fi
        else
            # Fedora
            dnf install -y redis
        fi

        # Start and enable Redis
        systemctl enable redis
        systemctl start redis

        SERVICE_NAME="redis"
        CONF_FILE="/etc/redis.conf"
        ;;

    arch)
        echo "Installing Redis on Arch Linux..."
        pacman -Sy --noconfirm redis

        # Start and enable Redis
        systemctl enable redis
        systemctl start redis

        SERVICE_NAME="redis"
        CONF_FILE="/etc/redis/redis.conf"
        ;;

    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Wait for Redis to be ready
sleep 2

# Test Redis connection
echo "Testing Redis connection..."
if redis-cli ping > /dev/null 2>&1; then
    echo "Redis is responding correctly!"
else
    echo "Warning: Redis might not be running properly"
fi

# Check service status
echo ""
echo "========================================="
echo "Redis Installation Complete!"
echo "========================================="
systemctl status $SERVICE_NAME --no-pager

echo ""
echo "Redis has been installed successfully!"
echo "Default port: 6379"
echo "Default bind address: 127.0.0.1"
echo ""
echo "To connect to Redis:"
echo "  redis-cli"
echo ""
echo "Test connection:"
echo "  redis-cli ping"
echo ""
echo "Configuration file: $CONF_FILE"
echo ""
echo "Security recommendations:"
echo "  1. Set a password: Add 'requirepass your_password' to $CONF_FILE"
echo "  2. Bind to specific IP if needed"
echo "  3. Configure firewall rules"
echo "  4. Set maxmemory limit"
echo ""
echo "After changing configuration, restart Redis:"
echo "  sudo systemctl restart $SERVICE_NAME"
