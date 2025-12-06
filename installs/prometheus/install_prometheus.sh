#!/bin/bash

# Prometheus Installation Script
# This script installs Prometheus on Linux systems

set -e

echo "========================================="
echo "Prometheus Installation Script"
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

# Prometheus version to install
PROMETHEUS_VERSION="2.48.0"
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

echo "Installing Prometheus ${PROMETHEUS_VERSION} for ${ARCH_TYPE}..."

# Create prometheus user
echo "Creating prometheus user..."
if ! id -u prometheus > /dev/null 2>&1; then
    useradd --no-create-home --shell /bin/false prometheus
fi

# Create directories
echo "Creating directories..."
mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus

# Download Prometheus
echo "Downloading Prometheus..."
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-${ARCH_TYPE}.tar.gz

# Extract archive
echo "Extracting Prometheus..."
tar -xzf prometheus-${PROMETHEUS_VERSION}.linux-${ARCH_TYPE}.tar.gz
cd prometheus-${PROMETHEUS_VERSION}.linux-${ARCH_TYPE}

# Copy binaries
echo "Installing binaries..."
cp prometheus /usr/local/bin/
cp promtool /usr/local/bin/

# Copy console files
cp -r consoles /etc/prometheus
cp -r console_libraries /etc/prometheus

# Set ownership
chown -R prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /var/lib/prometheus
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

# Create configuration file
echo "Creating configuration file..."
cat > /etc/prometheus/prometheus.yml <<EOF
# Prometheus configuration file
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets: []

# Load rules once and periodically evaluate them
rule_files:
  # - "alerts.yml"

# Scrape configurations
scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Node Exporter (uncomment if installed)
  # - job_name: 'node-exporter'
  #   static_configs:
  #     - targets: ['localhost:9100']
EOF

chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Create systemd service
echo "Creating systemd service..."
cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus/ \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries \\
  --web.listen-address=0.0.0.0:9090 \\
  --storage.tsdb.retention.time=15d

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
systemctl daemon-reload

# Start and enable Prometheus
echo "Starting Prometheus service..."
systemctl start prometheus
systemctl enable prometheus

# Clean up
cd /tmp
rm -rf prometheus-${PROMETHEUS_VERSION}.linux-${ARCH_TYPE}
rm -f prometheus-${PROMETHEUS_VERSION}.linux-${ARCH_TYPE}.tar.gz

# Wait for Prometheus to be ready
sleep 3

# Check service status
echo ""
echo "========================================="
echo "Prometheus Installation Complete!"
echo "========================================="
systemctl status prometheus --no-pager

echo ""
echo "Prometheus has been installed successfully!"
echo "Version: ${PROMETHEUS_VERSION}"
echo ""
echo "Access Prometheus at: http://localhost:9090"
echo ""
echo "Configuration file: /etc/prometheus/prometheus.yml"
echo "Data directory: /var/lib/prometheus"
echo "Binary location: /usr/local/bin/prometheus"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status prometheus"
echo "  sudo systemctl restart prometheus"
echo "  sudo journalctl -u prometheus -f"
echo ""
echo "To add targets, edit /etc/prometheus/prometheus.yml"
echo "Then reload: sudo systemctl reload prometheus"
