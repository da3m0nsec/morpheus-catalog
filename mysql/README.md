# MySQL/MariaDB Installation and Configuration

This directory contains scripts and documentation for installing and configuring MySQL/MariaDB.

## Contents

- `install_mysql.sh` - Installation script for MySQL/MariaDB

## Installation

Run the installation script:

```bash
bash install_mysql.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges

## Features

- Automated installation of MySQL/MariaDB
- Basic configuration setup
- Service management
- Initial security configuration

## Usage

After installation, MySQL will be available as a system service:

```bash
# Start MySQL
sudo systemctl start mysql      # Debian/Ubuntu
sudo systemctl start mariadb    # CentOS/RHEL/Fedora

# Stop MySQL
sudo systemctl stop mysql       # Debian/Ubuntu
sudo systemctl stop mariadb     # CentOS/RHEL/Fedora

# Check status
sudo systemctl status mysql     # Debian/Ubuntu
sudo systemctl status mariadb   # CentOS/RHEL/Fedora

# Enable on boot
sudo systemctl enable mysql     # Debian/Ubuntu
sudo systemctl enable mariadb   # CentOS/RHEL/Fedora
```

## Configuration

MySQL configuration files are typically located at:
- `/etc/mysql/` - Main configuration directory (Debian/Ubuntu)
- `/etc/my.cnf` or `/etc/my.cnf.d/` - Configuration files (CentOS/RHEL)
- `/var/lib/mysql/` - Data directory

## Default Access

- Default port: `3306`
- Default root user: `root`
- Root password: Set during installation

## Connecting to MySQL

```bash
# Connect as root
sudo mysql -u root -p

# Or on some systems without password initially
sudo mysql
```

## Basic Commands

```sql
-- Show databases
SHOW DATABASES;

-- Create a database
CREATE DATABASE myapp;

-- Create a user
CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'mypassword';

-- Grant privileges
GRANT ALL PRIVILEGES ON myapp.* TO 'myuser'@'localhost';
FLUSH PRIVILEGES;

-- Show users
SELECT user, host FROM mysql.user;
```

## Security Notes

- Run `mysql_secure_installation` after installation
- Set a strong root password
- Remove anonymous users
- Disable remote root login for production
- Use SSL/TLS for remote connections
- Keep MySQL updated
- Limit network access via firewall
