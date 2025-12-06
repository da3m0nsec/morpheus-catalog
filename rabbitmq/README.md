# RabbitMQ Installation and Configuration

This directory contains scripts and documentation for installing and configuring RabbitMQ.

## Contents

- `install_rabbitmq.sh` - Installation script for RabbitMQ

## Installation

Run the installation script:

```bash
bash install_rabbitmq.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges
- Erlang (installed automatically)

## Features

- Automated installation of RabbitMQ
- Erlang installation
- Management plugin enabled
- Admin user creation
- Service management

## Usage

After installation, RabbitMQ will be available as a system service:

```bash
# Start RabbitMQ
sudo systemctl start rabbitmq-server

# Stop RabbitMQ
sudo systemctl stop rabbitmq-server

# Check status
sudo systemctl status rabbitmq-server

# Enable on boot
sudo systemctl enable rabbitmq-server

# View logs
sudo journalctl -u rabbitmq-server -f
```

## Configuration

RabbitMQ configuration files are located at:
- `/etc/rabbitmq/rabbitmq.conf` - Main configuration file
- `/etc/rabbitmq/enabled_plugins` - Enabled plugins
- `/var/lib/rabbitmq/` - Data directory
- `/var/log/rabbitmq/` - Log files

## Default Access

- AMQP port: `5672`
- Management UI port: `15672`
- Management API: `http://localhost:15672/api/`
- Default guest user: `guest/guest` (localhost only)

## Management Interface

Access RabbitMQ Management UI:
```
http://your-server-ip:15672
```

Default admin credentials are created during installation.

## RabbitMQ CLI Commands

```bash
# List queues
sudo rabbitmqctl list_queues

# List exchanges
sudo rabbitmqctl list_exchanges

# List bindings
sudo rabbitmqctl list_bindings

# List users
sudo rabbitmqctl list_users

# List virtual hosts
sudo rabbitmqctl list_vhosts

# Check cluster status
sudo rabbitmqctl cluster_status

# Check node status
sudo rabbitmqctl status
```

## User Management

```bash
# Add a new user
sudo rabbitmqctl add_user myuser mypassword

# Set user as administrator
sudo rabbitmqctl set_user_tags myuser administrator

# Grant permissions
sudo rabbitmqctl set_permissions -p / myuser ".*" ".*" ".*"

# Delete a user
sudo rabbitmqctl delete_user myuser

# Change password
sudo rabbitmqctl change_password myuser newpassword
```

## Virtual Hosts

```bash
# Add virtual host
sudo rabbitmqctl add_vhost myvhost

# Delete virtual host
sudo rabbitmqctl delete_vhost myvhost

# List virtual hosts
sudo rabbitmqctl list_vhosts

# Set permissions on vhost
sudo rabbitmqctl set_permissions -p myvhost myuser ".*" ".*" ".*"
```

## Plugins

```bash
# List plugins
sudo rabbitmq-plugins list

# Enable plugin
sudo rabbitmq-plugins enable plugin_name

# Disable plugin
sudo rabbitmq-plugins disable plugin_name

# Commonly used plugins
sudo rabbitmq-plugins enable rabbitmq_management
sudo rabbitmq-plugins enable rabbitmq_shovel
sudo rabbitmq-plugins enable rabbitmq_federation
```

## Basic Python Example

```python
import pika

# Connect to RabbitMQ
connection = pika.BlockingConnection(
    pika.ConnectionParameters('localhost')
)
channel = connection.channel()

# Declare a queue
channel.queue_declare(queue='hello')

# Publish a message
channel.basic_publish(
    exchange='',
    routing_key='hello',
    body='Hello World!'
)

print("Message sent!")

# Close connection
connection.close()
```

## Monitoring

### Management UI
- Overview of queues, exchanges, connections
- Message rates and statistics
- Node health and memory usage

### Prometheus Integration
Enable prometheus plugin:
```bash
sudo rabbitmq-plugins enable rabbitmq_prometheus
```

Metrics available at: `http://localhost:15692/metrics`

## Performance Tuning

### Memory Management
Edit `/etc/rabbitmq/rabbitmq.conf`:
```ini
# Set memory high watermark (40% of total RAM)
vm_memory_high_watermark.relative = 0.4

# Set disk free space limit
disk_free_limit.absolute = 50GB
```

### Connection Limits
```ini
# Maximum number of connections
connection_max = 65536

# Channel max per connection
channel_max = 2047
```

## Clustering

```bash
# On node2, join node1
sudo rabbitmqctl stop_app
sudo rabbitmqctl join_cluster rabbit@node1
sudo rabbitmqctl start_app

# Check cluster status
sudo rabbitmqctl cluster_status
```

## High Availability

Create HA policy:
```bash
sudo rabbitmqctl set_policy ha-all "^" '{"ha-mode":"all"}'
```

## Security Best Practices

- Change default guest password or disable guest user
- Use strong passwords for admin users
- Enable TLS/SSL for production
- Use virtual hosts to isolate applications
- Configure firewall rules
- Enable authentication and authorization
- Regular backups of definitions and messages
- Keep RabbitMQ and Erlang updated
- Monitor memory and disk usage

## Backup and Restore

### Export definitions
```bash
# Export all definitions
sudo rabbitmqctl export_definitions /tmp/definitions.json

# Import definitions
sudo rabbitmqctl import_definitions /tmp/definitions.json
```

## Troubleshooting

Check logs:
```bash
sudo journalctl -u rabbitmq-server -n 100
tail -f /var/log/rabbitmq/rabbit@hostname.log
```

Reset RabbitMQ (WARNING: deletes all data):
```bash
sudo rabbitmqctl stop_app
sudo rabbitmqctl reset
sudo rabbitmqctl start_app
```

Check port usage:
```bash
sudo netstat -tulpn | grep -E '5672|15672'
```

## Useful Resources

- RabbitMQ Documentation: https://www.rabbitmq.com/documentation.html
- Management Plugin: https://www.rabbitmq.com/management.html
- Clustering Guide: https://www.rabbitmq.com/clustering.html
- Production Checklist: https://www.rabbitmq.com/production-checklist.html
