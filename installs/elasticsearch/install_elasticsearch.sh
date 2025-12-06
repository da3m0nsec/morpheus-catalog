#!/bin/bash

# Elasticsearch Installation Script
# This script installs Elasticsearch on Linux systems

set -e

echo "========================================="
echo "Elasticsearch Installation Script"
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

# Elasticsearch version
ELASTICSEARCH_VERSION="8.x"

# Install Elasticsearch based on OS
case $OS in
    ubuntu|debian)
        echo "Installing Elasticsearch on Debian/Ubuntu..."

        # Install dependencies
        apt-get update
        apt-get install -y apt-transport-https wget gnupg

        # Import Elasticsearch GPG key
        wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

        # Add Elasticsearch repository
        echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | \
            tee /etc/apt/sources.list.d/elastic-8.x.list

        # Update and install Elasticsearch
        apt-get update
        apt-get install -y elasticsearch

        # Configure Elasticsearch to start on boot
        systemctl daemon-reload
        systemctl enable elasticsearch
        ;;

    centos|rhel|fedora)
        echo "Installing Elasticsearch on RHEL/CentOS/Fedora..."

        # Import Elasticsearch GPG key
        rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

        # Create repository file
        cat > /etc/yum.repos.d/elasticsearch.repo <<EOF
[elasticsearch]
name=Elasticsearch repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

        # Install Elasticsearch
        if command -v dnf &> /dev/null; then
            dnf install -y elasticsearch
        else
            yum install -y elasticsearch
        fi

        # Configure Elasticsearch to start on boot
        systemctl daemon-reload
        systemctl enable elasticsearch
        ;;

    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Configure Elasticsearch for single-node
echo "Configuring Elasticsearch..."
cat >> /etc/elasticsearch/elasticsearch.yml <<EOF

# Single node configuration
discovery.type: single-node

# Network settings
network.host: 0.0.0.0

# Disable security for development (re-enable for production)
xpack.security.enabled: false
xpack.security.enrollment.enabled: false
xpack.security.http.ssl.enabled: false
xpack.security.transport.ssl.enabled: false
EOF

# Set JVM heap size (1GB for development)
sed -i 's/^-Xms.*/-Xms1g/' /etc/elasticsearch/jvm.options
sed -i 's/^-Xmx.*/-Xmx1g/' /etc/elasticsearch/jvm.options

# Increase virtual memory map count
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144

# Start Elasticsearch
echo "Starting Elasticsearch service..."
systemctl start elasticsearch

# Wait for Elasticsearch to start
echo "Waiting for Elasticsearch to start..."
sleep 15

# Check if Elasticsearch is responding
echo "Testing Elasticsearch connection..."
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:9200 > /dev/null 2>&1; then
        echo "Elasticsearch is responding!"
        break
    fi
    echo "Waiting for Elasticsearch to be ready... (attempt $((RETRY_COUNT+1))/$MAX_RETRIES)"
    sleep 2
    RETRY_COUNT=$((RETRY_COUNT+1))
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "Warning: Elasticsearch might not be running properly. Check logs with:"
    echo "  sudo journalctl -u elasticsearch"
fi

# Check service status
echo ""
echo "========================================="
echo "Elasticsearch Installation Complete!"
echo "========================================="
systemctl status elasticsearch --no-pager

echo ""
echo "Elasticsearch has been installed successfully!"
echo ""
echo "Access Elasticsearch at: http://localhost:9200"
echo ""
echo "Test the installation:"
echo "  curl -X GET \"localhost:9200/\""
echo "  curl -X GET \"localhost:9200/_cluster/health?pretty\""
echo ""
echo "Configuration file: /etc/elasticsearch/elasticsearch.yml"
echo "JVM options: /etc/elasticsearch/jvm.options"
echo "Data directory: /var/lib/elasticsearch"
echo "Log directory: /var/log/elasticsearch"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status elasticsearch"
echo "  sudo systemctl restart elasticsearch"
echo "  sudo journalctl -u elasticsearch -f"
echo ""
echo "IMPORTANT: Security is DISABLED for development."
echo "For production, enable security features in elasticsearch.yml"
echo ""
echo "To adjust heap size, edit: /etc/elasticsearch/jvm.options"
echo "  -Xms1g  # Initial heap size"
echo "  -Xmx1g  # Maximum heap size"
