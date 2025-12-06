# Nginx Linux Installer

A Python script that installs and configures nginx on Linux systems.

## Supported Operating Systems

- **Linux**
  - Debian/Ubuntu (apt)
  - RHEL/CentOS/Fedora (yum/dnf)
  - Arch Linux (pacman)

## Requirements

- Python 3.6 or higher
- Administrative privileges (sudo)
- Linux operating system

## Usage

### Install, Configure, and Start nginx (One Command)

```bash
sudo python3 install_nginx.py --all
```

This will:
1. Install nginx using your distribution's package manager
2. Configure nginx with a basic setup
3. Create a beautiful default website
4. Test the configuration
5. Start and enable the nginx service

### Individual Operations

#### Install nginx

```bash
sudo python3 install_nginx.py --install
```

#### Configure nginx

```bash
sudo python3 install_nginx.py --configure
```

Note: This automatically creates a default website with a modern, responsive design.

#### Test Configuration

```bash
sudo python3 install_nginx.py --test
```

#### Start nginx Service

```bash
sudo python3 install_nginx.py --start
```

#### Check nginx Status

```bash
sudo python3 install_nginx.py --status
```

### Combining Operations

You can combine multiple operations in a single command:

```bash
sudo python3 install_nginx.py --install --configure --start
```

## Features

- **Automatic Distribution Detection**: Detects Debian/Ubuntu, RHEL/CentOS/Fedora, or Arch Linux
- **Package Manager Integration**: Uses native package managers (apt, yum/dnf, pacman)
- **Configuration Backup**: Automatically backs up existing nginx.conf before modification
- **Default Website**: Creates a beautiful, modern landing page with animations
- **Service Management**: Starts and enables nginx service using systemctl or service commands
- **Configuration Testing**: Validates nginx configuration before applying

## Default Website

The script automatically creates a stunning default website featuring:

- Gradient background with purple/blue theme
- Animated rocket logo
- Glass-morphism design with frosted glass effects
- Responsive layout that works on all devices
- Server information display
- Helpful next steps guide

The website is accessible at `http://localhost` after installation.

## Configuration

The script creates a basic nginx configuration with:

- Auto-detection of worker processes
- Access and error logging
- Gzip compression enabled
- Include support for additional config files in `conf.d/`
- Default server block listening on port 80

### File Locations

- **nginx config**: `/etc/nginx/nginx.conf`
- **Site config**: `/etc/nginx/conf.d/default.conf`
- **Web root**: `/var/www/html`
- **Default page**: `/var/www/html/index.html`

## Troubleshooting

### Permission Denied

Make sure you're running the script with administrative privileges:

```bash
sudo python3 install_nginx.py --all
```

### nginx Already Installed

If nginx is already installed, the script will detect it and skip installation. You can still use `--configure` and `--start` options.

### Unsupported Linux Distribution

The script supports Debian/Ubuntu, RHEL/CentOS/Fedora, and Arch Linux. If you're using a different distribution, you may need to install nginx manually.

## Example Workflow

```bash
# Complete installation and setup
sudo python3 install_nginx.py --all

# Verify nginx is running
curl http://localhost

# Or open in a browser
xdg-open http://localhost

# Check status
sudo python3 install_nginx.py --status
```

## Customization

After installation, you can:

1. Replace `/var/www/html/index.html` with your own website
2. Add additional server blocks in `/etc/nginx/conf.d/`
3. Modify the main configuration in `/etc/nginx/nginx.conf`
4. Test your changes with `nginx -t`
5. Reload nginx with `systemctl reload nginx`

## License

MIT
