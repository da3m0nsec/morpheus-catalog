#!/bin/bash

# Node Exporter Installation Script
# This script installs Prometheus Node Exporter on Linux systems

set -e

echo "========================================="
echo "Node Exporter Installation Script"
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

# Node Exporter version to install
NODE_EXPORTER_VERSION="1.7.0"
ARCH=$(uname -m)

# Determine architecture
case $ARCH in
    x86_64)
        ARCH_TYPE="amd64"
        ;;
    aarch64|arm64)
        ARCH_TYPE="arm64"
        ;;
    armv7l)
        ARCH_TYPE="armv7"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Installing Node Exporter ${NODE_EXPORTER_VERSION} for ${ARCH_TYPE}..."

# Create node_exporter user
echo "Creating node_exporter user..."
if ! id -u node_exporter > /dev/null 2>&1; then
    useradd --no-create-home --shell /bin/false node_exporter
fi

# Download Node Exporter
echo "Downloading Node Exporter..."
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-${ARCH_TYPE}.tar.gz

# Extract archive
echo "Extracting Node Exporter..."
tar -xzf node_exporter-${NODE_EXPORTER_VERSION}.linux-${ARCH_TYPE}.tar.gz
cd node_exporter-${NODE_EXPORTER_VERSION}.linux-${ARCH_TYPE}

# Copy binary
echo "Installing binary..."
cp node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create systemd service
echo "Creating systemd service..."
cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter \\
  --web.listen-address=:9100

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
systemctl daemon-reload

# Start and enable Node Exporter
echo "Starting Node Exporter service..."
systemctl start node_exporter
systemctl enable node_exporter

# Clean up
cd /tmp
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-${ARCH_TYPE}
rm -f node_exporter-${NODE_EXPORTER_VERSION}.linux-${ARCH_TYPE}.tar.gz

# Wait for Node Exporter to be ready
sleep 2

# Test metrics endpoint
echo "Testing Node Exporter..."
if curl -s http://localhost:9100/metrics > /dev/null; then
    echo "Node Exporter is responding correctly!"
else
    echo "Warning: Node Exporter might not be running properly"
fi

# Check service status
echo ""
echo "========================================="
echo "Node Exporter Installation Complete!"
echo "========================================="
systemctl status node_exporter --no-pager

echo ""
echo "Node Exporter has been installed successfully!"
echo "Version: ${NODE_EXPORTER_VERSION}"
echo ""
echo "Metrics available at: http://localhost:9100/metrics"
echo ""
echo "Binary location: /usr/local/bin/node_exporter"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status node_exporter"
echo "  sudo systemctl restart node_exporter"
echo "  sudo journalctl -u node_exporter -f"
echo "  curl http://localhost:9100/metrics"
echo ""
echo "To integrate with Prometheus, add this to /etc/prometheus/prometheus.yml:"
echo ""
echo "scrape_configs:"
echo "  - job_name: 'node-exporter'"
echo "    static_configs:"
echo "      - targets: ['localhost:9100']"
