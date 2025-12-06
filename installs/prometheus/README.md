# Prometheus Installation and Configuration

This directory contains scripts and documentation for installing and configuring Prometheus.

## Contents

- `install_prometheus.sh` - Installation script for Prometheus

## Installation

Run the installation script:

```bash
bash install_prometheus.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges
- Minimum 2GB RAM recommended

## Features

- Automated installation of Prometheus
- Systemd service configuration
- Basic scrape configuration
- Service management

## Usage

After installation, Prometheus will be available as a system service:

```bash
# Start Prometheus
sudo systemctl start prometheus

# Stop Prometheus
sudo systemctl stop prometheus

# Check status
sudo systemctl status prometheus

# Enable on boot
sudo systemctl enable prometheus

# View logs
sudo journalctl -u prometheus -f
```

## Configuration

Prometheus configuration files are located at:
- `/etc/prometheus/prometheus.yml` - Main configuration file
- `/etc/prometheus/` - Configuration directory
- `/var/lib/prometheus/` - Data directory
- `/usr/local/bin/prometheus` - Binary location

## Default Access

- Default port: `9090`
- Web UI: `http://localhost:9090`
- Metrics endpoint: `http://localhost:9090/metrics`

## Web Interface

Access Prometheus web UI:
```
http://your-server-ip:9090
```

Features:
- Query interface (PromQL)
- Targets status
- Configuration viewer
- Graph visualization
- Alert status

## Basic Queries (PromQL)

```promql
# CPU usage
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100

# Disk usage
100 - ((node_filesystem_avail_bytes{mountpoint="/",fstype!="rootfs"} / node_filesystem_size_bytes{mountpoint="/",fstype!="rootfs"}) * 100)

# HTTP request rate
rate(http_requests_total[5m])
```

## Adding Targets

Edit `/etc/prometheus/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'my-application'
    static_configs:
      - targets: ['app-server:8080']
```

After editing, reload configuration:
```bash
sudo systemctl reload prometheus
```

## Integration with Grafana

1. Add Prometheus as a data source in Grafana
2. URL: `http://localhost:9090`
3. Access: Server (default)
4. Import community dashboards (e.g., Node Exporter Full)

## Common Exporters

- **Node Exporter** (9100): System metrics
- **MySQL Exporter** (9104): MySQL metrics
- **Redis Exporter** (9121): Redis metrics
- **PostgreSQL Exporter** (9187): PostgreSQL metrics
- **MongoDB Exporter** (9216): MongoDB metrics
- **Nginx Exporter** (9113): Nginx metrics

## Security Notes

- Configure authentication for production
- Use reverse proxy with HTTPS
- Restrict network access via firewall
- Secure inter-component communication
- Keep Prometheus updated
- Limit data retention based on storage
- Use service discovery instead of static targets in production

## Data Retention

Default retention: 15 days

To change retention, edit systemd service:
```bash
sudo systemctl edit prometheus
```

Add:
```ini
[Service]
ExecStart=
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --storage.tsdb.retention.time=30d
```

## Useful Resources

- Prometheus Documentation: https://prometheus.io/docs/
- PromQL Basics: https://prometheus.io/docs/prometheus/latest/querying/basics/
- Exporters List: https://prometheus.io/docs/instrumenting/exporters/
