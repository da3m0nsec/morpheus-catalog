# Zabbix Installation and Configuration

This directory contains scripts and documentation for installing and configuring Zabbix.

## Contents

- `install_zabbix.sh` - Installation script for Zabbix Server

## Installation

Run the installation script:

```bash
bash install_zabbix.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges
- Database server (MySQL/PostgreSQL) - will be installed if not present
- Web server (Apache/Nginx) - will be installed if not present
- PHP

## Features

- Automated installation of Zabbix Server
- Database setup (MySQL/PostgreSQL)
- Web server configuration
- Service management

## Usage

After installation, Zabbix services will be available:

```bash
# Start Zabbix Server
sudo systemctl start zabbix-server

# Stop Zabbix Server
sudo systemctl stop zabbix-server

# Check status
sudo systemctl status zabbix-server

# Enable on boot
sudo systemctl enable zabbix-server
```

## Configuration

Zabbix configuration files are typically located at:
- `/etc/zabbix/zabbix_server.conf` - Server configuration
- `/etc/zabbix/web/zabbix.conf.php` - Web frontend configuration
- `/usr/share/zabbix/` - Web frontend files

## Default Access

- Default web port: `80` or `443` (HTTPS)
- Default URL: `http://localhost/zabbix`
- Default username: `Admin`
- Default password: `zabbix`

## Web Interface

After installation, access Zabbix through your web browser:

```
http://your-server-ip/zabbix
```

## Components

- **Zabbix Server**: Main server process for monitoring
- **Zabbix Frontend**: Web interface for configuration and visualization
- **Zabbix Agent**: Installed on monitored hosts (optional, separate installation)
- **Database**: Stores configuration and collected data

## First Login

1. Navigate to `http://localhost/zabbix`
2. Login with username: `Admin` and password: `zabbix`
3. Change the default password immediately
4. Start configuring hosts and monitoring

## Security Notes

- Change the default Admin password immediately
- Configure HTTPS/SSL for production use
- Set up proper user authentication
- Configure firewall rules (default ports: 10050, 10051)
- Keep Zabbix updated
- Secure the database with strong passwords
