# Node Exporter Installation and Configuration

This directory contains scripts and documentation for installing and configuring Prometheus Node Exporter.

## Contents

- `install_node_exporter.sh` - Installation script for Node Exporter

## Installation

Run the installation script:

```bash
bash install_node_exporter.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges
- Prometheus server (recommended)

## Features

- Automated installation of Node Exporter
- Systemd service configuration
- System metrics collection
- Service management

## Usage

After installation, Node Exporter will be available as a system service:

```bash
# Start Node Exporter
sudo systemctl start node_exporter

# Stop Node Exporter
sudo systemctl stop node_exporter

# Check status
sudo systemctl status node_exporter

# Enable on boot
sudo systemctl enable node_exporter

# View logs
sudo journalctl -u node_exporter -f
```

## Default Access

- Default port: `9100`
- Metrics endpoint: `http://localhost:9100/metrics`

## Metrics Endpoint

View metrics:
```bash
curl http://localhost:9100/metrics
```

## Collected Metrics

Node Exporter exposes a wide variety of hardware and OS metrics:

### System Metrics
- CPU usage and statistics
- Memory usage and statistics
- Disk I/O statistics
- Network interface statistics
- File system usage
- System load average

### Hardware Metrics
- Temperature sensors
- Fan speeds
- Power supply status
- RAID status (if available)

### Process Metrics
- Number of processes
- Process states
- Context switches
- Interrupts

## Integration with Prometheus

Add this target to your Prometheus configuration (`/etc/prometheus/prometheus.yml`):

```yaml
scrape_configs:
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
        labels:
          instance: 'server-1'
```

Then reload Prometheus:
```bash
sudo systemctl reload prometheus
```

## Grafana Dashboards

Popular Node Exporter dashboards:
- **Node Exporter Full** (ID: 1860)
- **Node Exporter Server Metrics** (ID: 11074)
- **Node Exporter for Prometheus** (ID: 13978)

Import in Grafana:
1. Go to Dashboards → Import
2. Enter dashboard ID
3. Select Prometheus data source
4. Import

## Common Queries

```promql
# CPU Usage
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory Usage Percentage
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))

# Disk Usage
100 - ((node_filesystem_avail_bytes{mountpoint="/",fstype!="rootfs"} / node_filesystem_size_bytes{mountpoint="/",fstype!="rootfs"}) * 100)

# Network Traffic
irate(node_network_receive_bytes_total[5m])
irate(node_network_transmit_bytes_total[5m])

# System Load
node_load1
node_load5
node_load15
```

## Enabled Collectors

By default, Node Exporter enables many collectors. You can view them at:
```
http://localhost:9100/
```

## Disabling/Enabling Collectors

Edit `/etc/systemd/system/node_exporter.service` to customize:

```ini
ExecStart=/usr/local/bin/node_exporter \
  --collector.disable-defaults \
  --collector.cpu \
  --collector.meminfo \
  --collector.diskstats \
  --collector.filesystem
```

## Security Notes

- Bind to localhost if only local access needed
- Use firewall rules to restrict access
- Consider using TLS for remote access
- Monitor for unauthorized access
- Keep Node Exporter updated

## Troubleshooting

Check if Node Exporter is running:
```bash
sudo systemctl status node_exporter
```

View logs:
```bash
sudo journalctl -u node_exporter -n 50
```

Test metrics endpoint:
```bash
curl -s http://localhost:9100/metrics | head
```

## Useful Resources

- Node Exporter Documentation: https://github.com/prometheus/node_exporter
- Prometheus Documentation: https://prometheus.io/docs/
