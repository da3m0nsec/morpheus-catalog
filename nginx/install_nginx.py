#!/usr/bin/env python3
"""
Linux nginx installer and configurator.
Supports Debian/Ubuntu, RHEL/CentOS/Fedora, and Arch Linux.
"""

import os
import sys
import platform
import subprocess
import shutil
from pathlib import Path
from typing import Optional, Dict, List


class NginxInstaller:
    """Linux nginx installer and configurator."""

    def __init__(self):
        self.system = platform.system().lower()
        self.machine = platform.machine()
        self.nginx_config_path: Optional[Path] = None
        self.nginx_binary: Optional[str] = None

    def detect_linux_distro(self) -> Optional[str]:
        """Detect Linux distribution."""
        if not self.system == 'linux':
            return None

        # Check for distribution-specific files
        if Path('/etc/debian_version').exists():
            return 'debian'
        elif Path('/etc/redhat-release').exists():
            return 'redhat'
        elif Path('/etc/arch-release').exists():
            return 'arch'

        # Fallback to checking /etc/os-release
        try:
            with open('/etc/os-release', 'r') as f:
                content = f.read().lower()
                if 'ubuntu' in content or 'debian' in content:
                    return 'debian'
                elif 'centos' in content or 'rhel' in content or 'fedora' in content:
                    return 'redhat'
                elif 'arch' in content:
                    return 'arch'
        except FileNotFoundError:
            pass

        return None

    def is_admin(self) -> bool:
        """Check if running with administrative privileges."""
        return os.geteuid() == 0

    def run_command(self, cmd: List[str], check=True, shell=False) -> subprocess.CompletedProcess:
        """Run a system command."""
        print(f"Running: {' '.join(cmd)}")
        return subprocess.run(cmd, check=check, shell=shell, capture_output=True, text=True)

    def install_debian(self):
        """Install nginx on Debian/Ubuntu systems."""
        print("Installing nginx on Debian/Ubuntu...")
        self.run_command(['apt-get', 'update'])
        self.run_command(['apt-get', 'install', '-y', 'nginx'])
        self.nginx_config_path = Path('/etc/nginx')
        self.nginx_binary = 'nginx'

    def install_redhat(self):
        """Install nginx on RHEL/CentOS/Fedora systems."""
        print("Installing nginx on RHEL/CentOS/Fedora...")

        # Try dnf first (Fedora, newer CentOS), fallback to yum
        if shutil.which('dnf'):
            self.run_command(['dnf', 'install', '-y', 'nginx'])
        else:
            self.run_command(['yum', 'install', '-y', 'nginx'])

        self.nginx_config_path = Path('/etc/nginx')
        self.nginx_binary = 'nginx'

    def install_arch(self):
        """Install nginx on Arch Linux."""
        print("Installing nginx on Arch Linux...")
        self.run_command(['pacman', '-Sy', '--noconfirm', 'nginx'])
        self.nginx_config_path = Path('/etc/nginx')
        self.nginx_binary = 'nginx'

    def install(self):
        """Install nginx based on the detected OS."""
        if not self.is_admin():
            print("ERROR: This script requires administrative privileges.")
            print("Please run with sudo")
            sys.exit(1)

        # Check if nginx is already installed
        if shutil.which('nginx'):
            print("nginx is already installed.")
            self.nginx_binary = 'nginx'

            # Try to detect config path
            result = subprocess.run(['nginx', '-V'], capture_output=True, text=True, stderr=subprocess.STDOUT)
            if result.returncode == 0:
                for line in result.stdout.split():
                    if '--conf-path=' in line:
                        config_file = line.split('--conf-path=')[1]
                        self.nginx_config_path = Path(config_file).parent
                        break

            # Fallback to common paths
            if not self.nginx_config_path:
                if Path('/etc/nginx').exists():
                    self.nginx_config_path = Path('/etc/nginx')

            return

        print(f"Detected OS: {self.system}")

        if self.system != 'linux':
            print(f"ERROR: This script only supports Linux. Detected OS: {self.system}")
            sys.exit(1)

        distro = self.detect_linux_distro()
        print(f"Detected Linux distribution: {distro}")

        if distro == 'debian':
            self.install_debian()
        elif distro == 'redhat':
            self.install_redhat()
        elif distro == 'arch':
            self.install_arch()
        else:
            print(f"Unsupported Linux distribution: {distro}")
            sys.exit(1)

        print(f"nginx installed successfully!")
        print(f"Config path: {self.nginx_config_path}")
        print(f"Binary: {self.nginx_binary}")

    def configure(self, config_dict: Optional[Dict] = None):
        """Configure nginx with custom settings."""
        if not self.nginx_config_path:
            print("ERROR: nginx config path not found. Please install nginx first.")
            sys.exit(1)

        config_file = self.nginx_config_path / 'nginx.conf'

        # Backup existing config
        if config_file.exists():
            backup_file = config_file.with_suffix('.conf.backup')
            print(f"Backing up existing config to {backup_file}")
            shutil.copy2(config_file, backup_file)

        # Create a basic nginx configuration
        default_config = """
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
"""

        print(f"Writing configuration to {config_file}")
        with open(config_file, 'w') as f:
            f.write(default_config.strip())

        # Create necessary directories
        conf_d = self.nginx_config_path / 'conf.d'
        conf_d.mkdir(exist_ok=True)
        print(f"Created config directory: {conf_d}")

    def create_default_site(self):
        """Create a default website with HTML content."""
        print("Creating default website...")

        # Create web root directory
        web_root = Path('/var/www/html')
        web_root.mkdir(parents=True, exist_ok=True)

        # Create a cool HTML page
        html_content = """<!DOCTYPE html>
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
"""

        # Write HTML file
        index_file = web_root / 'index.html'
        print(f"Writing default website to {index_file}")
        with open(index_file, 'w') as f:
            f.write(html_content)

        # Create nginx site configuration
        site_config = """server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }
}
"""

        # Write site configuration
        if self.nginx_config_path:
            site_config_file = self.nginx_config_path / 'conf.d' / 'default.conf'
            print(f"Writing site configuration to {site_config_file}")
            with open(site_config_file, 'w') as f:
                f.write(site_config)

        print("Default website created successfully!")
        print("Visit http://localhost to see your new website")

    def start(self):
        """Start nginx service."""
        print("Starting nginx...")

        # Try systemctl first, fallback to service command
        try:
            self.run_command(['systemctl', 'start', 'nginx'])
            self.run_command(['systemctl', 'enable', 'nginx'])
        except subprocess.CalledProcessError:
            self.run_command(['service', 'nginx', 'start'])

        print("nginx started successfully!")

    def test_config(self):
        """Test nginx configuration."""
        print("Testing nginx configuration...")

        if self.nginx_binary:
            result = self.run_command([self.nginx_binary, '-t'], check=False)
            if result.returncode == 0:
                print("Configuration test passed!")
                return True
            else:
                print("Configuration test failed!")
                print(result.stderr)
                return False
        else:
            result = self.run_command(['nginx', '-t'], check=False)
            return result.returncode == 0

    def status(self):
        """Check nginx status."""
        print("Checking nginx status...")

        try:
            result = self.run_command(['systemctl', 'status', 'nginx'], check=False)
            print(result.stdout)
        except subprocess.CalledProcessError:
            result = self.run_command(['service', 'nginx', 'status'], check=False)
            print(result.stdout)


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(description='Linux nginx installer and configurator')
    parser.add_argument('--install', action='store_true', help='Install nginx')
    parser.add_argument('--configure', action='store_true', help='Configure nginx')
    parser.add_argument('--start', action='store_true', help='Start nginx service')
    parser.add_argument('--test', action='store_true', help='Test nginx configuration')
    parser.add_argument('--status', action='store_true', help='Check nginx status')
    parser.add_argument('--all', action='store_true', help='Install, configure, and start nginx')

    args = parser.parse_args()

    installer = NginxInstaller()

    try:
        if args.all:
            installer.install()
            installer.configure()
            installer.create_default_site()
            installer.test_config()
            installer.start()
        else:
            if args.install:
                installer.install()
            if args.configure:
                installer.configure()
                installer.create_default_site()
            if args.test:
                installer.test_config()
            if args.start:
                installer.start()
            if args.status:
                installer.status()

        if not any([args.install, args.configure, args.start, args.test, args.status, args.all]):
            parser.print_help()

    except KeyboardInterrupt:
        print("\nOperation cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
