#!/bin/bash

# Zabbix Installation Script
# This script installs Zabbix Server on Linux systems

set -e

echo "========================================="
echo "Zabbix Server Installation Script"
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
    VERSION_CODENAME=${VERSION_CODENAME:-""}
else
    echo "Cannot detect OS version"
    exit 1
fi

echo "Detected OS: $OS $VERSION"

# Zabbix version
ZABBIX_VERSION="7.0"

# Install Zabbix based on OS
case $OS in
    ubuntu|debian)
        echo "Installing Zabbix on Debian/Ubuntu..."

        # Download and install Zabbix repository
        if [ "$OS" = "ubuntu" ]; then
            wget https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu${VERSION}_all.deb
            dpkg -i zabbix-release_latest+ubuntu${VERSION}_all.deb
            rm -f zabbix-release_latest+ubuntu${VERSION}_all.deb
        else
            wget https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/debian/pool/main/z/zabbix-release/zabbix-release_latest+debian${VERSION%%.*}_all.deb
            dpkg -i zabbix-release_latest+debian${VERSION%%.*}_all.deb
            rm -f zabbix-release_latest+debian${VERSION%%.*}_all.deb
        fi

        # Update package list
        apt-get update

        # Install Zabbix server, frontend, and agent
        apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

        # Install MySQL if not present
        if ! command -v mysql &> /dev/null; then
            echo "Installing MySQL server..."
            apt-get install -y mysql-server
            systemctl start mysql
            systemctl enable mysql
        fi

        # Create database
        echo "Creating Zabbix database..."
        mysql -e "CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
        mysql -e "CREATE USER IF NOT EXISTS 'zabbix'@'localhost' IDENTIFIED BY 'zabbix_password';"
        mysql -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
        mysql -e "SET GLOBAL log_bin_trust_function_creators = 1;"
        mysql -e "FLUSH PRIVILEGES;"

        # Import initial schema
        echo "Importing database schema..."
        zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 zabbix

        mysql -e "SET GLOBAL log_bin_trust_function_creators = 0;"

        # Configure Zabbix server database connection
        sed -i 's/# DBPassword=/DBPassword=zabbix_password/' /etc/zabbix/zabbix_server.conf
        ;;

    centos|rhel|fedora)
        echo "Installing Zabbix on RHEL/CentOS/Fedora..."

        # Install Zabbix repository
        rpm -Uvh https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/rhel/${VERSION%%.*}/x86_64/zabbix-release-${ZABBIX_VERSION}-1.el${VERSION%%.*}.noarch.rpm

        if command -v dnf &> /dev/null; then
            dnf clean all
            dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent

            # Install MySQL/MariaDB if not present
            if ! command -v mysql &> /dev/null; then
                echo "Installing MariaDB server..."
                dnf install -y mariadb-server
                systemctl start mariadb
                systemctl enable mariadb
            fi
        else
            yum clean all
            yum install -y zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent

            # Install MySQL/MariaDB if not present
            if ! command -v mysql &> /dev/null; then
                echo "Installing MariaDB server..."
                yum install -y mariadb-server
                systemctl start mariadb
                systemctl enable mariadb
            fi
        fi

        # Create database
        echo "Creating Zabbix database..."
        mysql -e "CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
        mysql -e "CREATE USER IF NOT EXISTS 'zabbix'@'localhost' IDENTIFIED BY 'zabbix_password';"
        mysql -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
        mysql -e "SET GLOBAL log_bin_trust_function_creators = 1;"
        mysql -e "FLUSH PRIVILEGES;"

        # Import initial schema
        echo "Importing database schema..."
        zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 zabbix

        mysql -e "SET GLOBAL log_bin_trust_function_creators = 0;"

        # Configure Zabbix server database connection
        sed -i 's/# DBPassword=/DBPassword=zabbix_password/' /etc/zabbix/zabbix_server.conf
        ;;

    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Start and enable services
echo "Starting Zabbix services..."
systemctl restart zabbix-server zabbix-agent apache2 2>/dev/null || systemctl restart zabbix-server zabbix-agent httpd 2>/dev/null || true
systemctl enable zabbix-server zabbix-agent apache2 2>/dev/null || systemctl enable zabbix-server zabbix-agent httpd 2>/dev/null || true

# Check service status
echo ""
echo "========================================="
echo "Zabbix Installation Complete!"
echo "========================================="
systemctl status zabbix-server --no-pager || true

echo ""
echo "Zabbix has been installed successfully!"
echo ""
echo "Access Zabbix web interface at: http://localhost/zabbix"
echo ""
echo "Default credentials:"
echo "  Username: Admin"
echo "  Password: zabbix"
echo ""
echo "Database credentials:"
echo "  Database: zabbix"
echo "  User: zabbix"
echo "  Password: zabbix_password"
echo ""
echo "IMPORTANT: Change default passwords immediately!"
echo ""
echo "Configuration file: /etc/zabbix/zabbix_server.conf"
