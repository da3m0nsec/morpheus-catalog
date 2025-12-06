# Apache HTTP Server Installation and Configuration

This directory contains scripts and documentation for installing and configuring Apache HTTP Server.

## Contents

- `install_apache.sh` - Installation script for Apache HTTP Server

## Installation

Run the installation script:

```bash
bash install_apache.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges

## Features

- Automated installation of Apache HTTP Server
- Basic virtual host configuration
- Module management
- Service management
- SSL/TLS support

## Usage

After installation, Apache will be available as a system service:

```bash
# Start Apache
sudo systemctl start apache2    # Debian/Ubuntu
sudo systemctl start httpd      # CentOS/RHEL/Fedora

# Stop Apache
sudo systemctl stop apache2     # Debian/Ubuntu
sudo systemctl stop httpd       # CentOS/RHEL/Fedora

# Restart Apache
sudo systemctl restart apache2  # Debian/Ubuntu
sudo systemctl restart httpd    # CentOS/RHEL/Fedora

# Reload configuration
sudo systemctl reload apache2   # Debian/Ubuntu
sudo systemctl reload httpd     # CentOS/RHEL/Fedora

# Check status
sudo systemctl status apache2   # Debian/Ubuntu
sudo systemctl status httpd     # CentOS/RHEL/Fedora

# Enable on boot
sudo systemctl enable apache2   # Debian/Ubuntu
sudo systemctl enable httpd     # CentOS/RHEL/Fedora
```

## Configuration

Apache configuration files are located at:
- Debian/Ubuntu: `/etc/apache2/`
  - Main config: `/etc/apache2/apache2.conf`
  - Sites: `/etc/apache2/sites-available/`
  - Modules: `/etc/apache2/mods-available/`
- CentOS/RHEL: `/etc/httpd/`
  - Main config: `/etc/httpd/conf/httpd.conf`
  - Virtual hosts: `/etc/httpd/conf.d/`

## Default Access

- Default HTTP port: `80`
- Default HTTPS port: `443`
- Default document root:
  - Debian/Ubuntu: `/var/www/html`
  - CentOS/RHEL: `/var/www/html`

## Web Interface

Access Apache default page:
```
http://your-server-ip
```

## Document Root

Default web files location:
```bash
# Debian/Ubuntu & CentOS/RHEL
/var/www/html/
```

Create a test page:
```bash
echo "<h1>Hello from Apache!</h1>" | sudo tee /var/www/html/index.html
```

## Virtual Hosts

### Debian/Ubuntu

Create virtual host:
```bash
sudo nano /etc/apache2/sites-available/example.com.conf
```

```apache
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/example.com

    <Directory /var/www/example.com>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/example.com-error.log
    CustomLog ${APACHE_LOG_DIR}/example.com-access.log combined
</VirtualHost>
```

Enable site:
```bash
sudo mkdir -p /var/www/example.com
sudo a2ensite example.com.conf
sudo systemctl reload apache2
```

### CentOS/RHEL

Create virtual host:
```bash
sudo nano /etc/httpd/conf.d/example.com.conf
```

```apache
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/example.com

    <Directory /var/www/example.com>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/httpd/example.com-error.log
    CustomLog /var/log/httpd/example.com-access.log combined
</VirtualHost>
```

Reload Apache:
```bash
sudo mkdir -p /var/www/example.com
sudo systemctl reload httpd
```

## SSL/TLS Configuration

### Install SSL Certificate (Let's Encrypt)

```bash
# Debian/Ubuntu
sudo apt-get install certbot python3-certbot-apache
sudo certbot --apache -d example.com -d www.example.com

# CentOS/RHEL
sudo yum install certbot python3-certbot-apache
sudo certbot --apache -d example.com -d www.example.com
```

### Manual SSL Configuration

```apache
<VirtualHost *:443>
    ServerName example.com
    DocumentRoot /var/www/example.com

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/example.com.crt
    SSLCertificateKeyFile /etc/ssl/private/example.com.key
    SSLCertificateChainFile /etc/ssl/certs/example.com-chain.crt

    <Directory /var/www/example.com>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

Enable SSL module:
```bash
# Debian/Ubuntu
sudo a2enmod ssl
sudo systemctl reload apache2

# CentOS/RHEL
# SSL module is usually enabled by default
```

## Apache Modules

### Debian/Ubuntu

```bash
# List available modules
apache2ctl -M

# Enable module
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod ssl

# Disable module
sudo a2dismod status

# Reload Apache
sudo systemctl reload apache2
```

### CentOS/RHEL

Modules are configured in `/etc/httpd/conf.modules.d/`

## Common Modules

- **mod_rewrite**: URL rewriting
- **mod_ssl**: SSL/TLS support
- **mod_headers**: HTTP headers manipulation
- **mod_proxy**: Reverse proxy
- **mod_deflate**: Compression
- **mod_security**: Web application firewall

## .htaccess

Enable .htaccess:
```apache
<Directory /var/www/html>
    AllowOverride All
</Directory>
```

Example .htaccess:
```apache
# Enable rewrite engine
RewriteEngine On

# Redirect HTTP to HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Custom error pages
ErrorDocument 404 /error404.html
ErrorDocument 500 /error500.html
```

## Reverse Proxy Configuration

Enable modules:
```bash
# Debian/Ubuntu
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo systemctl reload apache2

# CentOS/RHEL - usually enabled
```

Configure proxy:
```apache
<VirtualHost *:80>
    ServerName api.example.com

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/
</VirtualHost>
```

## Performance Tuning

Edit configuration:
```apache
# Timeout settings
Timeout 60
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5

# MPM Prefork settings (default)
<IfModule mpm_prefork_module>
    StartServers             5
    MinSpareServers          5
    MaxSpareServers         10
    MaxRequestWorkers      150
    MaxConnectionsPerChild   0
</IfModule>

# MPM Worker settings (better for high traffic)
<IfModule mpm_worker_module>
    StartServers             2
    MinSpareThreads         25
    MaxSpareThreads         75
    ThreadLimit             64
    ThreadsPerChild         25
    MaxRequestWorkers      150
    MaxConnectionsPerChild   0
</IfModule>
```

## Monitoring

### Server Status

Enable mod_status:
```bash
# Debian/Ubuntu
sudo a2enmod status
```

Configuration:
```apache
<Location /server-status>
    SetHandler server-status
    Require ip 127.0.0.1
</Location>
```

Access: `http://localhost/server-status`

### Logs

```bash
# Debian/Ubuntu
tail -f /var/log/apache2/access.log
tail -f /var/log/apache2/error.log

# CentOS/RHEL
tail -f /var/log/httpd/access_log
tail -f /var/log/httpd/error_log
```

## Security Best Practices

- Keep Apache updated
- Disable directory listing (`Options -Indexes`)
- Hide Apache version (`ServerTokens Prod`, `ServerSignature Off`)
- Use SSL/TLS for sensitive data
- Implement rate limiting
- Configure firewall rules
- Use ModSecurity WAF
- Regular security audits
- Limit request size
- Disable unnecessary modules

## Testing Configuration

```bash
# Test configuration syntax
# Debian/Ubuntu
sudo apache2ctl configtest

# CentOS/RHEL
sudo apachectl configtest

# Show loaded modules
# Debian/Ubuntu
apache2ctl -M

# CentOS/RHEL
httpd -M
```

## Troubleshooting

Check if Apache is running:
```bash
sudo systemctl status apache2  # Debian/Ubuntu
sudo systemctl status httpd    # CentOS/RHEL
```

Check port usage:
```bash
sudo netstat -tulpn | grep -E ':80|:443'
```

View error logs:
```bash
# Debian/Ubuntu
sudo tail -n 50 /var/log/apache2/error.log

# CentOS/RHEL
sudo tail -n 50 /var/log/httpd/error_log
```

## Useful Resources

- Apache Documentation: https://httpd.apache.org/docs/
- Apache Virtual Host: https://httpd.apache.org/docs/2.4/vhosts/
- Apache Modules: https://httpd.apache.org/docs/2.4/mod/
- Apache Security Tips: https://httpd.apache.org/docs/2.4/misc/security_tips.html
