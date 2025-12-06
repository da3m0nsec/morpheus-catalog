# Nginx Linux Installer

A bash script that installs and configures nginx on Linux systems.

## Supported Operating Systems

- **Linux**
  - Debian/Ubuntu (apt)
  - RHEL/CentOS/Fedora (yum/dnf)
  - Arch Linux (pacman)

## Requirements

- Bash shell
- Root privileges (sudo)
- Linux operating system

## Installation

1. Download the script:
```bash
curl -O https://raw.githubusercontent.com/yourusername/yourrepo/main/nginx/install_nginx.sh
chmod +x install_nginx.sh
```

Or clone the repository:
```bash
git clone https://github.com/yourusername/yourrepo.git
cd yourrepo/nginx
chmod +x install_nginx.sh
```

## Usage

### Quick Start - Complete Installation

Install, configure, and start nginx with a single command:

```bash
sudo ./install_nginx.sh
```

Note: If no options are provided, `--all` is used by default.

You can also explicitly use:
```bash
sudo ./install_nginx.sh --all
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
sudo ./install_nginx.sh --install
```

#### Configure nginx

```bash
sudo ./install_nginx.sh --configure
```

Note: This automatically creates a default website with a modern, responsive design.

#### Test Configuration

```bash
sudo ./install_nginx.sh --test
```

#### Start nginx Service

```bash
sudo ./install_nginx.sh --start
```

#### Check nginx Status

```bash
sudo ./install_nginx.sh --status
```

### Combining Operations

You can combine multiple operations in a single command:

```bash
sudo ./install_nginx.sh --install --configure --start
```

### Get Help

```bash
./install_nginx.sh --help
```

## Features

- **Automatic Distribution Detection**: Detects Debian/Ubuntu, RHEL/CentOS/Fedora, or Arch Linux
- **Package Manager Integration**: Uses native package managers (apt, yum/dnf, pacman)
- **Configuration Backup**: Automatically backs up existing nginx.conf before modification
- **Default Website**: Creates a beautiful, modern landing page with animations
- **Service Management**: Starts and enables nginx service using systemctl or service commands
- **Configuration Testing**: Validates nginx configuration before applying
- **Colored Output**: Clear, colored terminal output for better readability
- **Error Handling**: Exits on errors to prevent partial installations

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

Make sure you're running the script with root privileges:

```bash
sudo ./install_nginx.sh --all
```

### Script Not Executable

If you get a "Permission denied" error, make the script executable:

```bash
chmod +x install_nginx.sh
```

### nginx Already Installed

If nginx is already installed, the script will detect it and skip installation. You can still use `--configure` and `--start` options.

### Unsupported Linux Distribution

The script supports Debian/Ubuntu, RHEL/CentOS/Fedora, and Arch Linux. If you're using a different distribution, you may need to install nginx manually.

## Example Workflows

### Fresh Installation

```bash
# Download and run the script
curl -O https://example.com/install_nginx.sh
chmod +x install_nginx.sh
sudo ./install_nginx.sh

# Verify nginx is running
curl http://localhost

# Or open in a browser
xdg-open http://localhost
```

### Update Configuration Only

```bash
# Reconfigure nginx (backs up existing config)
sudo ./install_nginx.sh --configure --test

# Restart nginx to apply changes
sudo systemctl restart nginx
```

### Check Status

```bash
sudo ./install_nginx.sh --status
```

## Customization

After installation, you can:

1. Replace `/var/www/html/index.html` with your own website
2. Add additional server blocks in `/etc/nginx/conf.d/`
3. Modify the main configuration in `/etc/nginx/nginx.conf`
4. Test your changes with `nginx -t`
5. Reload nginx with `systemctl reload nginx`

### Example: Add a New Site

```bash
# Create a new site configuration
sudo nano /etc/nginx/conf.d/mysite.conf

# Test the configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

## Uninstallation

To remove nginx:

```bash
# Debian/Ubuntu
sudo apt-get remove --purge nginx nginx-common
sudo rm -rf /etc/nginx /var/www/html

# RHEL/CentOS/Fedora
sudo dnf remove nginx  # or: sudo yum remove nginx
sudo rm -rf /etc/nginx /var/www/html

# Arch Linux
sudo pacman -Rns nginx
sudo rm -rf /etc/nginx /var/www/html
```

## License

MIT
