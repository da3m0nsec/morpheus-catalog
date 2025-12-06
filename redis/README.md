# Redis Installation and Configuration

This directory contains scripts and documentation for installing and configuring Redis.

## Contents

- `install_redis.sh` - Installation script for Redis

## Installation

Run the installation script:

```bash
bash install_redis.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges

## Features

- Automated installation of Redis
- Basic configuration setup
- Service management
- Memory optimization

## Usage

After installation, Redis will be available as a system service:

```bash
# Start Redis
sudo systemctl start redis

# Stop Redis
sudo systemctl stop redis

# Check status
sudo systemctl status redis

# Enable on boot
sudo systemctl enable redis
```

## Configuration

Redis configuration file is typically located at:
- `/etc/redis/redis.conf` - Main configuration file
- `/var/lib/redis/` - Data directory
- `/var/log/redis/` - Log directory

## Default Access

- Default port: `6379`
- Default bind address: `127.0.0.1` (localhost only)
- No authentication by default

## Connecting to Redis

```bash
# Using redis-cli
redis-cli

# Test connection
redis-cli ping
# Should return: PONG

# Connect to specific host/port
redis-cli -h localhost -p 6379
```

## Basic Commands

```bash
# Set a key
SET mykey "Hello Redis"

# Get a key
GET mykey

# Check if key exists
EXISTS mykey

# Delete a key
DEL mykey

# List all keys (use with caution in production)
KEYS *

# Get info about Redis
INFO

# Monitor commands in real-time
MONITOR
```

## Performance Tuning

- Configure `maxmemory` limit
- Set appropriate `maxmemory-policy`
- Enable persistence (RDB/AOF) based on needs
- Tune `tcp-backlog` for high concurrency

## Security Notes

- Enable authentication with `requirepass`
- Bind to localhost only unless remote access needed
- Use firewall rules to restrict access
- Disable dangerous commands in production
- Use SSL/TLS for remote connections (Redis 6+)
- Keep Redis updated
- Consider using Redis ACLs (Redis 6+)

## Common Use Cases

- Caching layer
- Session storage
- Message broker (Pub/Sub)
- Real-time analytics
- Leaderboards and counters
- Rate limiting
