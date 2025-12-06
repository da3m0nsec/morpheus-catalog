# Grafana Installation and Configuration

This directory contains scripts and documentation for installing and configuring Grafana.

## Contents

- `install_grafana.sh` - Installation script for Grafana

## Installation

Run the installation script:

```bash
bash install_grafana.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges

## Features

- Automated installation of Grafana
- Basic configuration setup
- Service management

## Usage

After installation, Grafana will be available as a system service:

```bash
# Start Grafana
sudo systemctl start grafana-server

# Stop Grafana
sudo systemctl stop grafana-server

# Check status
sudo systemctl status grafana-server

# Enable on boot
sudo systemctl enable grafana-server
```

## Configuration

Grafana configuration files are typically located at:
- `/etc/grafana/grafana.ini` - Main configuration file
- `/var/lib/grafana/` - Data directory
- `/var/log/grafana/` - Log directory

## Default Access

- Default port: `3000`
- Default URL: `http://localhost:3000`
- Default username: `admin`
- Default password: `admin` (you will be prompted to change on first login)

## Web Interface

After installation, access Grafana through your web browser:

```
http://your-server-ip:3000
```

## First Login

1. Navigate to `http://localhost:3000`
2. Login with username: `admin` and password: `admin`
3. You will be prompted to set a new password
4. Start creating dashboards and adding data sources

## Security Notes

- Change the default admin password immediately
- Configure HTTPS/SSL for production use
- Set up proper authentication (LDAP, OAuth, etc.)
- Configure firewall rules appropriately
- Keep Grafana updated
