#!/bin/bash
#
# Linux nginx installer and configurator
# Supports Debian/Ubuntu, RHEL/CentOS/Fedora, and Arch Linux
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NGINX_CONFIG_PATH="/etc/nginx"
WEB_ROOT="/var/www/html"

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        echo "Please run with sudo: sudo $0"
        exit 1
    fi
}

# Detect Linux distribution
detect_distro() {
    if [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]]; then
        echo "redhat"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                echo "debian"
                ;;
            centos|rhel|fedora)
                echo "redhat"
                ;;
            arch)
                echo "arch"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    else
        echo "unknown"
    fi
}

# Install nginx on Debian/Ubuntu
install_debian() {
    print_info "Installing nginx on Debian/Ubuntu..."
    apt-get update
    apt-get install -y nginx
    print_success "nginx installed successfully"
}

# Install nginx on RHEL/CentOS/Fedora
install_redhat() {
    print_info "Installing nginx on RHEL/CentOS/Fedora..."
    if command -v dnf &> /dev/null; then
        dnf install -y nginx
    else
        yum install -y nginx
    fi
    print_success "nginx installed successfully"
}

# Install nginx on Arch Linux
install_arch() {
    print_info "Installing nginx on Arch Linux..."
    pacman -Sy --noconfirm nginx
    print_success "nginx installed successfully"
}

# Install nginx based on detected distribution
install_nginx() {
    if command -v nginx &> /dev/null; then
        print_warning "nginx is already installed"
        nginx -v
        return 0
    fi

    local distro=$(detect_distro)
    print_info "Detected distribution: $distro"

    case "$distro" in
        debian)
            install_debian
            ;;
        redhat)
            install_redhat
            ;;
        arch)
            install_arch
            ;;
        *)
            print_error "Unsupported Linux distribution: $distro"
            exit 1
            ;;
    esac
}

# Configure nginx
configure_nginx() {
    print_info "Configuring nginx..."

    # Backup existing config
    if [[ -f "${NGINX_CONFIG_PATH}/nginx.conf" ]]; then
        print_info "Backing up existing configuration..."
        cp "${NGINX_CONFIG_PATH}/nginx.conf" "${NGINX_CONFIG_PATH}/nginx.conf.backup"
    fi

    # Create main nginx configuration
    cat > "${NGINX_CONFIG_PATH}/nginx.conf" << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65;
    gzip on;

    include /etc/nginx/conf.d/*.conf;
}
EOF

    # Create conf.d directory if it doesn't exist
    mkdir -p "${NGINX_CONFIG_PATH}/conf.d"

    print_success "nginx configuration created"
}

# Create default website
create_default_site() {
    print_info "Creating default website..."

    # Create web root directory
    mkdir -p "${WEB_ROOT}"

    # Create HTML file
    cat > "${WEB_ROOT}/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to nginx!</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            color: #fff;
        }

        .container {
            text-align: center;
            padding: 2rem;
            max-width: 800px;
        }

        .logo {
            font-size: 4rem;
            margin-bottom: 1rem;
            animation: bounce 2s infinite;
        }

        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-20px); }
        }

        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }

        p {
            font-size: 1.2rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }

        .info-box {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 2rem;
            margin-top: 2rem;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .info-box h2 {
            font-size: 1.5rem;
            margin-bottom: 1rem;
        }

        .info-box ul {
            list-style: none;
            text-align: left;
            display: inline-block;
        }

        .info-box li {
            margin: 0.5rem 0;
            padding: 0.5rem;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 5px;
        }

        .info-box li::before {
            content: "✓ ";
            color: #4ade80;
            font-weight: bold;
            margin-right: 0.5rem;
        }

        .footer {
            margin-top: 2rem;
            opacity: 0.7;
            font-size: 0.9rem;
        }

        .pulse {
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo pulse">🚀</div>
        <h1>nginx is running!</h1>
        <p>Your web server has been successfully installed and configured.</p>

        <div class="info-box">
            <h2>Server Information</h2>
            <ul>
                <li>Web Server: nginx</li>
                <li>Status: Active and Running</li>
                <li>Configuration: /etc/nginx/nginx.conf</li>
                <li>Document Root: /var/www/html</li>
            </ul>
        </div>

        <div class="info-box">
            <h2>Next Steps</h2>
            <ul>
                <li>Upload your website files to /var/www/html</li>
                <li>Configure virtual hosts in /etc/nginx/conf.d/</li>
                <li>Test configuration with: nginx -t</li>
                <li>Reload nginx with: systemctl reload nginx</li>
            </ul>
        </div>

        <div class="footer">
            <p>Installed with the nginx installer script</p>
        </div>
    </div>
</body>
</html>
EOF

    # Create site configuration
    cat > "${NGINX_CONFIG_PATH}/conf.d/default.conf" << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

    print_success "Default website created at ${WEB_ROOT}/index.html"
    print_info "Visit http://localhost to see your website"
}

# Test nginx configuration
test_config() {
    print_info "Testing nginx configuration..."
    if nginx -t; then
        print_success "Configuration test passed"
        return 0
    else
        print_error "Configuration test failed"
        return 1
    fi
}

# Start nginx service
start_nginx() {
    print_info "Starting nginx service..."

    if command -v systemctl &> /dev/null; then
        systemctl start nginx
        systemctl enable nginx
        print_success "nginx service started and enabled"
    elif command -v service &> /dev/null; then
        service nginx start
        print_success "nginx service started"
    else
        print_error "Could not find systemctl or service command"
        return 1
    fi
}

# Check nginx status
check_status() {
    print_info "Checking nginx status..."

    if command -v systemctl &> /dev/null; then
        systemctl status nginx
    elif command -v service &> /dev/null; then
        service nginx status
    else
        print_error "Could not find systemctl or service command"
        return 1
    fi
}

# Show usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Linux nginx installer and configurator
Supports Debian/Ubuntu, RHEL/CentOS/Fedora, and Arch Linux

If no options are provided, --all is used by default.

OPTIONS:
    --install       Install nginx
    --configure     Configure nginx and create default website
    --test          Test nginx configuration
    --start         Start nginx service
    --status        Check nginx status
    --all           Install, configure, test, and start nginx (default)
    --help          Show this help message

EXAMPLES:
    # Complete installation and setup (default behavior)
    sudo $0
    # or explicitly:
    sudo $0 --all

    # Install and configure only
    sudo $0 --install --configure

    # Check status
    sudo $0 --status

EOF
}

# Main function
main() {
    local do_install=false
    local do_configure=false
    local do_test=false
    local do_start=false
    local do_status=false
    local do_all=false

    # Parse arguments
    # If no arguments provided, default to --all
    if [[ $# -eq 0 ]]; then
        do_all=true
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            --install)
                do_install=true
                shift
                ;;
            --configure)
                do_configure=true
                shift
                ;;
            --test)
                do_test=true
                shift
                ;;
            --start)
                do_start=true
                shift
                ;;
            --status)
                do_status=true
                shift
                ;;
            --all)
                do_all=true
                shift
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Check root privileges
    check_root

    # Execute requested operations
    if [[ "$do_all" == true ]]; then
        install_nginx
        configure_nginx
        create_default_site
        test_config
        start_nginx
        echo ""
        print_success "nginx installation and configuration complete!"
        print_info "Visit http://localhost to see your website"
    else
        [[ "$do_install" == true ]] && install_nginx
        if [[ "$do_configure" == true ]]; then
            configure_nginx
            create_default_site
        fi
        [[ "$do_test" == true ]] && test_config
        [[ "$do_start" == true ]] && start_nginx
        [[ "$do_status" == true ]] && check_status
    fi
}

# Run main function
main "$@"
