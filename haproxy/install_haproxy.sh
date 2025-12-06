#!/bin/bash

# HAProxy Installation Script
# This script installs HAProxy on Linux systems

set -e

echo "========================================="
echo "HAProxy Installation Script"
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

# Install HAProxy based on OS
case $OS in
    ubuntu|debian)
        echo "Installing HAProxy on Debian/Ubuntu..."

        # Update package list
        apt-get update

        # Install HAProxy
        apt-get install -y haproxy

        # Enable HAProxy
        systemctl enable haproxy
        ;;

    centos|rhel|fedora)
        echo "Installing HAProxy on RHEL/CentOS/Fedora..."

        # Install HAProxy
        if command -v dnf &> /dev/null; then
            dnf install -y haproxy
        else
            yum install -y haproxy
        fi

        # Enable HAProxy
        systemctl enable haproxy
        ;;

    arch)
        echo "Installing HAProxy on Arch Linux..."
        pacman -Sy --noconfirm haproxy
        systemctl enable haproxy
        ;;

    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Backup original configuration
if [ -f /etc/haproxy/haproxy.cfg ]; then
    cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.backup.$(date +%Y%m%d_%H%M%S)
fi

# Create basic configuration with statistics page
echo "Creating basic HAProxy configuration..."
cat > /etc/haproxy/haproxy.cfg <<'EOF'
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

    # Default SSL material locations
    ca-base /etc/ssl/certs
    crt-base /etc/ssl/private

    # Default ciphers to use on SSL-enabled listening sockets.
    ssl-default-bind-ciphers ECDHE+AESGCM:ECDHE+AES256:ECDHE+AES128:!SSLv3:!TLSv1
    ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11

#---------------------------------------------------------------------
# Defaults
#---------------------------------------------------------------------
defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

#---------------------------------------------------------------------
# Statistics page
#---------------------------------------------------------------------
listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
    stats auth admin:admin
    stats admin if TRUE

#---------------------------------------------------------------------
# Frontend configuration (example)
#---------------------------------------------------------------------
# Uncomment and configure your frontend
# frontend http_front
#     bind *:80
#     default_backend http_back

#---------------------------------------------------------------------
# Backend configuration (example)
#---------------------------------------------------------------------
# Uncomment and configure your backend servers
# backend http_back
#     balance roundrobin
#     option httpchk GET /
#     server web1 192.168.1.10:80 check
#     server web2 192.168.1.11:80 check
EOF

# Create HAProxy runtime directory if it doesn't exist
mkdir -p /run/haproxy
chown haproxy:haproxy /run/haproxy

# Validate configuration
echo "Validating HAProxy configuration..."
haproxy -c -f /etc/haproxy/haproxy.cfg

# Start HAProxy
echo "Starting HAProxy service..."
systemctl start haproxy

# Wait for HAProxy to start
sleep 2

# Check service status
echo ""
echo "========================================="
echo "HAProxy Installation Complete!"
echo "========================================="
systemctl status haproxy --no-pager

echo ""
echo "HAProxy has been installed successfully!"
echo ""
echo "Statistics page: http://localhost:8404/stats"
echo "Default credentials: admin / admin"
echo ""
echo "Configuration file: /etc/haproxy/haproxy.cfg"
echo "Backup saved to: /etc/haproxy/haproxy.cfg.backup.*"
echo ""
echo "To configure HAProxy for your environment:"
echo "  1. Edit /etc/haproxy/haproxy.cfg"
echo "  2. Add your frontend and backend configurations"
echo "  3. Validate: sudo haproxy -c -f /etc/haproxy/haproxy.cfg"
echo "  4. Reload: sudo systemctl reload haproxy"
echo ""
echo "Example frontend configuration:"
echo "  frontend http_front"
echo "    bind *:80"
echo "    default_backend http_back"
echo ""
echo "Example backend configuration:"
echo "  backend http_back"
echo "    balance roundrobin"
echo "    server web1 192.168.1.10:80 check"
echo "    server web2 192.168.1.11:80 check"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status haproxy"
echo "  sudo systemctl reload haproxy"
echo "  sudo haproxy -c -f /etc/haproxy/haproxy.cfg"
echo "  sudo journalctl -u haproxy -f"
