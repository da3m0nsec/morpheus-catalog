#!/bin/bash

# MySQL/MariaDB Installation Script
# This script installs MySQL or MariaDB on Linux systems

set -e

echo "========================================="
echo "MySQL/MariaDB Installation Script"
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

# Install MySQL/MariaDB based on OS
case $OS in
    ubuntu|debian)
        echo "Installing MySQL on Debian/Ubuntu..."

        # Update package list
        apt-get update

        # Set non-interactive mode
        export DEBIAN_FRONTEND=noninteractive

        # Install MySQL server
        apt-get install -y mysql-server mysql-client

        # Start and enable MySQL
        systemctl start mysql
        systemctl enable mysql

        SERVICE_NAME="mysql"
        ;;

    centos|rhel|fedora)
        echo "Installing MariaDB on RHEL/CentOS/Fedora..."

        # Install MariaDB
        if command -v dnf &> /dev/null; then
            dnf install -y mariadb-server mariadb
        else
            yum install -y mariadb-server mariadb
        fi

        # Start and enable MariaDB
        systemctl start mariadb
        systemctl enable mariadb

        SERVICE_NAME="mariadb"
        ;;

    arch)
        echo "Installing MariaDB on Arch Linux..."
        pacman -Sy --noconfirm mariadb

        # Initialize MariaDB data directory
        mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

        # Start and enable MariaDB
        systemctl start mariadb
        systemctl enable mariadb

        SERVICE_NAME="mariadb"
        ;;

    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Wait for MySQL to be ready
sleep 3

# Check service status
echo ""
echo "========================================="
echo "MySQL/MariaDB Installation Complete!"
echo "========================================="
systemctl status $SERVICE_NAME --no-pager

echo ""
echo "MySQL/MariaDB has been installed successfully!"
echo "Default port: 3306"
echo ""
echo "To secure your installation, run:"
echo "  sudo mysql_secure_installation"
echo ""
echo "To connect to MySQL:"
echo "  sudo mysql -u root -p"
echo ""
echo "Or on some systems:"
echo "  sudo mysql"
echo ""
echo "Configuration directory:"
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    echo "  /etc/mysql/"
else
    echo "  /etc/my.cnf or /etc/my.cnf.d/"
fi
echo "Data directory: /var/lib/mysql"
