#!/bin/bash

# PostgreSQL Installation Script
# This script installs PostgreSQL on Linux systems

set -e

echo "========================================="
echo "PostgreSQL Installation Script"
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

# Install PostgreSQL based on OS
case $OS in
    ubuntu|debian)
        echo "Installing PostgreSQL on Debian/Ubuntu..."
        apt-get update
        apt-get install -y postgresql postgresql-contrib
        ;;
    centos|rhel|fedora)
        echo "Installing PostgreSQL on RHEL/CentOS/Fedora..."
        if command -v dnf &> /dev/null; then
            dnf install -y postgresql-server postgresql-contrib
            postgresql-setup --initdb
        else
            yum install -y postgresql-server postgresql-contrib
            postgresql-setup initdb
        fi
        ;;
    arch)
        echo "Installing PostgreSQL on Arch Linux..."
        pacman -Sy --noconfirm postgresql
        sudo -u postgres initdb -D /var/lib/postgres/data
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Start and enable PostgreSQL service
echo "Starting PostgreSQL service..."
systemctl start postgresql
systemctl enable postgresql

# Check service status
echo ""
echo "========================================="
echo "PostgreSQL Installation Complete!"
echo "========================================="
systemctl status postgresql --no-pager

echo ""
echo "PostgreSQL has been installed successfully!"
echo "Default user: postgres"
echo "Default port: 5432"
echo ""
echo "To access PostgreSQL:"
echo "  sudo -u postgres psql"
echo ""
echo "Important: Please set a password for the postgres user:"
echo "  sudo -u postgres psql -c \"ALTER USER postgres PASSWORD 'your_password';\""
