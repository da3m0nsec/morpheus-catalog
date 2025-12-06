#!/bin/bash

# Apache HTTP Server Installation Script
# This script installs Apache HTTP Server on Linux systems

set -e

echo "========================================="
echo "Apache HTTP Server Installation Script"
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

# Install Apache based on OS
case $OS in
    ubuntu|debian)
        echo "Installing Apache on Debian/Ubuntu..."

        # Update package list
        apt-get update

        # Install Apache
        apt-get install -y apache2

        # Start and enable Apache
        systemctl start apache2
        systemctl enable apache2

        SERVICE_NAME="apache2"
        CONF_DIR="/etc/apache2"
        VHOST_DIR="/etc/apache2/sites-available"
        DOC_ROOT="/var/www/html"

        # Enable commonly used modules
        a2enmod rewrite
        a2enmod headers
        a2enmod ssl

        # Reload to apply modules
        systemctl reload apache2
        ;;

    centos|rhel|fedora)
        echo "Installing Apache on RHEL/CentOS/Fedora..."

        # Install Apache (httpd)
        if command -v dnf &> /dev/null; then
            dnf install -y httpd
        else
            yum install -y httpd
        fi

        # Start and enable Apache
        systemctl start httpd
        systemctl enable httpd

        SERVICE_NAME="httpd"
        CONF_DIR="/etc/httpd"
        VHOST_DIR="/etc/httpd/conf.d"
        DOC_ROOT="/var/www/html"

        # Configure firewall if firewalld is running
        if systemctl is-active --quiet firewalld; then
            echo "Configuring firewall..."
            firewall-cmd --permanent --add-service=http
            firewall-cmd --permanent --add-service=https
            firewall-cmd --reload
        fi
        ;;

    arch)
        echo "Installing Apache on Arch Linux..."
        pacman -Sy --noconfirm apache

        # Start and enable Apache
        systemctl start httpd
        systemctl enable httpd

        SERVICE_NAME="httpd"
        CONF_DIR="/etc/httpd"
        VHOST_DIR="/etc/httpd/conf"
        DOC_ROOT="/srv/http"
        ;;

    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Create a test index.html if it doesn't exist
if [ ! -f "$DOC_ROOT/index.html" ]; then
    echo "Creating default index.html..."
    cat > "$DOC_ROOT/index.html" <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Apache HTTP Server - Installed Successfully</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            max-width: 800px;
            margin: 0 auto;
        }
        h1 {
            color: #d22128;
        }
        .success {
            color: #28a745;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Apache HTTP Server</h1>
        <p class="success">✓ Installation Successful!</p>
        <p>Your Apache HTTP Server is now running and serving web pages.</p>
        <hr>
        <h2>What's Next?</h2>
        <ul>
            <li>Place your website files in: <code>DOC_ROOT_PLACEHOLDER</code></li>
            <li>Configure virtual hosts in: <code>VHOST_DIR_PLACEHOLDER</code></li>
            <li>View access logs for traffic information</li>
            <li>Enable SSL/TLS for secure connections</li>
        </ul>
        <h2>Useful Commands</h2>
        <ul>
            <li><code>sudo systemctl status SERVICE_NAME_PLACEHOLDER</code> - Check service status</li>
            <li><code>sudo systemctl restart SERVICE_NAME_PLACEHOLDER</code> - Restart Apache</li>
            <li><code>sudo systemctl reload SERVICE_NAME_PLACEHOLDER</code> - Reload configuration</li>
        </ul>
    </div>
</body>
</html>
EOF

    # Replace placeholders
    sed -i "s|DOC_ROOT_PLACEHOLDER|$DOC_ROOT|g" "$DOC_ROOT/index.html"
    sed -i "s|VHOST_DIR_PLACEHOLDER|$VHOST_DIR|g" "$DOC_ROOT/index.html"
    sed -i "s|SERVICE_NAME_PLACEHOLDER|$SERVICE_NAME|g" "$DOC_ROOT/index.html"

    # Set proper permissions
    chown -R www-data:www-data "$DOC_ROOT" 2>/dev/null || chown -R apache:apache "$DOC_ROOT" 2>/dev/null || true
fi

# Wait for Apache to be ready
sleep 2

# Test if Apache is responding
echo "Testing Apache..."
if curl -s http://localhost > /dev/null 2>&1; then
    echo "Apache is responding correctly!"
else
    echo "Warning: Apache might not be running properly"
fi

# Check service status
echo ""
echo "========================================="
echo "Apache HTTP Server Installation Complete!"
echo "========================================="
systemctl status $SERVICE_NAME --no-pager

echo ""
echo "Apache HTTP Server has been installed successfully!"
echo ""
echo "Access Apache at: http://localhost"
echo ""
echo "Service name: $SERVICE_NAME"
echo "Configuration directory: $CONF_DIR"
echo "Document root: $DOC_ROOT"
echo "Virtual hosts directory: $VHOST_DIR"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status $SERVICE_NAME"
echo "  sudo systemctl restart $SERVICE_NAME"
echo "  sudo systemctl reload $SERVICE_NAME"
echo ""
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    echo "  sudo apache2ctl configtest    - Test configuration"
    echo "  sudo a2enmod module_name      - Enable module"
    echo "  sudo a2dismod module_name     - Disable module"
    echo "  sudo a2ensite site_name       - Enable site"
    echo "  sudo a2dissite site_name      - Disable site"
    echo ""
    echo "Logs:"
    echo "  /var/log/apache2/access.log"
    echo "  /var/log/apache2/error.log"
else
    echo "  sudo apachectl configtest     - Test configuration"
    echo "  httpd -M                      - List loaded modules"
    echo ""
    echo "Logs:"
    echo "  /var/log/httpd/access_log"
    echo "  /var/log/httpd/error_log"
fi
echo ""
echo "To create a virtual host, see the README.md file"
