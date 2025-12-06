# Service Installation Scripts

This directory contains automated installation scripts for 17 popular infrastructure and application services.

## Available Services

### Web Servers & Load Balancers
- **[nginx](./nginx/)** - Web server and reverse proxy
- **[apache](./apache/)** - Apache HTTP Server
- **[haproxy](./haproxy/)** - Load balancer with HA support

### Application Servers
- **[tomcat](./tomcat/)** - Java application server

### Databases
- **[postgresql](./postgresql/)** - Relational database
- **[mongodb](./mongodb/)** - NoSQL document database
- **[mysql](./mysql/)** - MySQL/MariaDB relational database
- **[redis](./redis/)** - In-memory data store and cache
- **[elasticsearch](./elasticsearch/)** - Search and analytics engine

### Monitoring & Observability
- **[prometheus](./prometheus/)** - Metrics collection and storage
- **[node_exporter](./node_exporter/)** - System metrics exporter
- **[grafana](./grafana/)** - Visualization and dashboards
- **[zabbix](./zabbix/)** - Enterprise monitoring solution

### Messaging & Containers
- **[rabbitmq](./rabbitmq/)** - Message broker (AMQP)
- **[docker](./docker/)** - Container platform

## Quick Start

Each service directory contains:
- `README.md` - Detailed documentation and usage
- `install_[service].sh` - Automated installation script

### Install a Service

```bash
# Navigate to service directory
cd nginx/

# Read the documentation
cat README.md

# Run installation (requires root)
sudo bash install_nginx.sh
```

## Features

✅ **Multi-Distribution Support**: Ubuntu, Debian, CentOS, RHEL, Fedora, Arch Linux
✅ **Automated Installation**: One-command deployment
✅ **Production-Ready**: Security best practices included
✅ **Service Management**: Systemd integration
✅ **Post-Install Validation**: Automatic health checks

## Use with Morpheus

These scripts can be used to create:
- **Instance Types** - Custom Node Types in Morpheus
- **Automation Tasks** - Post-provisioning workflows
- **Golden Images** - Pre-configured VM templates

## Documentation

Each service includes comprehensive documentation:
- Installation requirements
- Configuration examples
- Security considerations
- Monitoring integration
- Troubleshooting guides
- Best practices

## Support

For deployment architectures using these services, see:
- **VM Deployments**: [../deployments/](../deployments/)
- **Kubernetes**: [../kubernetes/](../kubernetes/)
