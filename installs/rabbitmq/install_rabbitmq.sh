#!/bin/bash

# RabbitMQ Installation Script
# This script installs RabbitMQ on Linux systems

set -e

echo "========================================="
echo "RabbitMQ Installation Script"
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

# Install RabbitMQ based on OS
case $OS in
    ubuntu|debian)
        echo "Installing RabbitMQ on Debian/Ubuntu..."

        # Update package list
        apt-get update

        # Install dependencies
        apt-get install -y curl gnupg apt-transport-https

        ## Team RabbitMQ's main signing key
        curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | gpg --dearmor | tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null

        ## Community mirror of Cloudsmith: modern Erlang repository
        curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key | gpg --dearmor | tee /usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg > /dev/null

        ## Community mirror of Cloudsmith: RabbitMQ repository
        curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key | gpg --dearmor | tee /usr/share/keyrings/rabbitmq.9F4587F226208342.gpg > /dev/null

        ## Add apt repositories
        tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Provides modern Erlang/OTP releases
deb [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-erlang/deb/ubuntu $(lsb_release -sc) main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-erlang/deb/ubuntu $(lsb_release -sc) main

## Provides RabbitMQ
deb [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-server/deb/ubuntu $(lsb_release -sc) main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-server/deb/ubuntu $(lsb_release -sc) main
EOF

        # Update package list
        apt-get update

        # Install Erlang and RabbitMQ
        apt-get install -y erlang-base \
                        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl

        apt-get install -y rabbitmq-server
        ;;

    centos|rhel|fedora)
        echo "Installing RabbitMQ on RHEL/CentOS/Fedora..."

        # Install dependencies
        if command -v dnf &> /dev/null; then
            dnf install -y curl wget gnupg2
        else
            yum install -y curl wget gnupg2
        fi

        # Import signing keys
        rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc'
        rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key'
        rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key'

        # Add RabbitMQ repository
        cat > /etc/yum.repos.d/rabbitmq.repo <<'EOF'
[rabbitmq_erlang]
name=rabbitmq_erlang
baseurl=https://ppa1.novemberain.com/rabbitmq/rabbitmq-erlang/rpm/el/$releasever/$basearch
repo_gpgcheck=1
gpgcheck=1
enabled=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt

[rabbitmq_server]
name=rabbitmq_server
baseurl=https://ppa1.novemberain.com/rabbitmq/rabbitmq-server/rpm/el/$releasever/$basearch
repo_gpgcheck=1
gpgcheck=1
enabled=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

        # Install Erlang and RabbitMQ
        if command -v dnf &> /dev/null; then
            dnf install -y erlang rabbitmq-server
        else
            yum install -y erlang rabbitmq-server
        fi
        ;;

    arch)
        echo "Installing RabbitMQ on Arch Linux..."
        pacman -Sy --noconfirm rabbitmq
        ;;

    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Enable and start RabbitMQ
echo "Starting RabbitMQ service..."
systemctl enable rabbitmq-server
systemctl start rabbitmq-server

# Wait for RabbitMQ to start
sleep 5

# Enable management plugin
echo "Enabling management plugin..."
rabbitmq-plugins enable rabbitmq_management

# Create admin user
echo "Creating admin user..."
rabbitmqctl add_user admin admin || true
rabbitmqctl set_user_tags admin administrator
rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"

# Restart to apply changes
systemctl restart rabbitmq-server
sleep 5

# Check service status
echo ""
echo "========================================="
echo "RabbitMQ Installation Complete!"
echo "========================================="
systemctl status rabbitmq-server --no-pager

echo ""
echo "RabbitMQ has been installed successfully!"
echo ""
echo "Management UI: http://localhost:15672"
echo "AMQP Port: 5672"
echo ""
echo "Admin credentials:"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "IMPORTANT: Change the default password:"
echo "  sudo rabbitmqctl change_password admin NEW_PASSWORD"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status rabbitmq-server"
echo "  sudo systemctl restart rabbitmq-server"
echo "  sudo rabbitmqctl status"
echo "  sudo rabbitmqctl list_queues"
echo "  sudo rabbitmqctl list_users"
echo ""
echo "Configuration: /etc/rabbitmq/"
echo "Logs: /var/log/rabbitmq/"
