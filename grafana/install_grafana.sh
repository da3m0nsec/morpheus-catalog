#!/bin/bash

# Grafana Installation Script
# This script installs Grafana on Linux systems

set -e

echo "========================================="
echo "Grafana Installation Script"
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

# Install Grafana based on OS
case $OS in
    ubuntu|debian)
        echo "Installing Grafana on Debian/Ubuntu..."

        # Install prerequisites
        apt-get install -y apt-transport-https software-properties-common wget

        # Add Grafana GPG key
        mkdir -p /etc/apt/keyrings/
        wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null

        # Add Grafana repository
        echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | \
            tee /etc/apt/sources.list.d/grafana.list

        # Update and install Grafana
        apt-get update
        apt-get install -y grafana
        ;;

    centos|rhel|fedora)
        echo "Installing Grafana on RHEL/CentOS/Fedora..."

        # Create repository file
        cat > /etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

        # Install Grafana
        if command -v dnf &> /dev/null; then
            dnf install -y grafana
        else
            yum install -y grafana
        fi
        ;;

    arch)
        echo "Installing Grafana on Arch Linux..."
        pacman -Sy --noconfirm grafana
        ;;

    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Start and enable Grafana service
echo "Starting Grafana service..."
systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server

# Check service status
echo ""
echo "========================================="
echo "Grafana Installation Complete!"
echo "========================================="
systemctl status grafana-server --no-pager

echo ""
echo "Grafana has been installed successfully!"
echo "Access Grafana at: http://localhost:3000"
echo ""
echo "Default credentials:"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "You will be prompted to change the password on first login."
echo ""
echo "Configuration file: /etc/grafana/grafana.ini"
echo "Data directory: /var/lib/grafana"
echo "Log directory: /var/log/grafana"
