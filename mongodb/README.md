# MongoDB Installation and Configuration

This directory contains scripts and documentation for installing and configuring MongoDB.

## Contents

- `install_mongodb.sh` - Installation script for MongoDB

## Installation

Run the installation script:

```bash
bash install_mongodb.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges

## Features

- Automated installation of MongoDB
- Basic configuration setup
- Service management

## Usage

After installation, MongoDB will be available as a system service:

```bash
# Start MongoDB
sudo systemctl start mongod

# Stop MongoDB
sudo systemctl stop mongod

# Check status
sudo systemctl status mongod

# Enable on boot
sudo systemctl enable mongod
```

## Configuration

MongoDB configuration file is typically located at:
- `/etc/mongod.conf` - Main configuration file
- `/var/lib/mongodb/` - Data directory
- `/var/log/mongodb/` - Log directory

## Default Access

- Default port: `27017`
- Default bind address: `127.0.0.1` (localhost only)

## Connecting to MongoDB

```bash
# Using mongosh (MongoDB Shell)
mongosh

# Or using legacy mongo shell
mongo
```

## Security Notes

- Enable authentication in production environments
- Configure firewall rules to restrict access
- Use SSL/TLS for remote connections
- Keep MongoDB updated
- Bind to localhost only unless remote access is needed
