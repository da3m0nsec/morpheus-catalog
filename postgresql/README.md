# PostgreSQL Installation and Configuration

This directory contains scripts and documentation for installing and configuring PostgreSQL.

## Contents

- `install_postgresql.sh` - Installation script for PostgreSQL

## Installation

Run the installation script:

```bash
bash install_postgresql.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges

## Features

- Automated installation of PostgreSQL
- Basic configuration setup
- Service management

## Usage

After installation, PostgreSQL will be available as a system service:

```bash
# Start PostgreSQL
sudo systemctl start postgresql

# Stop PostgreSQL
sudo systemctl stop postgresql

# Check status
sudo systemctl status postgresql

# Enable on boot
sudo systemctl enable postgresql
```

## Configuration

PostgreSQL configuration files are typically located at:
- `/etc/postgresql/` - Main configuration directory
- `/var/lib/postgresql/` - Data directory

## Default Access

- Default user: `postgres`
- Default port: `5432`

## Security Notes

- Change default passwords after installation
- Configure `pg_hba.conf` for network access
- Use SSL/TLS for remote connections
- Keep PostgreSQL updated
