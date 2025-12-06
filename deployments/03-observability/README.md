# Observability Platform Deployment

Complete monitoring and observability stack for infrastructure and applications using open-source and enterprise tools.

## Architecture Overview

```
                    ┌─────────────────────┐
                    │  Monitored Systems  │
                    │  (Apps & Infra)     │
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
     ┌────────▼────────┐  ┌───▼────┐  ┌───────▼────────┐
     │ Node Exporter   │  │ Zabbix │  │ Log Agents     │
     │ :9100           │  │ Agent  │  │                │
     └────────┬────────┘  └───┬────┘  └───────┬────────┘
              │               │                │
     ┌────────▼────────┐  ┌───▼────────┐  ┌───▼────────┐
     │  Prometheus     │  │  Zabbix    │  │Elasticsearch│
     │  :9090          │  │  Server    │  │  :9200     │
     │  (Metrics)      │  │  :80       │  │  (Logs)    │
     └────────┬────────┘  └───┬────────┘  └───┬────────┘
              │               │                │
              └───────────────┼────────────────┘
                              │
                     ┌────────▼────────┐
                     │    Grafana      │
                     │    :3000        │
                     │  (Visualization)│
                     └─────────────────┘
```

## Components

### Metrics Collection

**Prometheus** (Time-series database)
- **Port**: 9090
- **Purpose**: Metrics collection, storage, and querying
- **Resources**: 2 vCPU, 8GB RAM, 100GB disk
- **Retention**: 15 days default

**Node Exporter** (Per monitored host)
- **Port**: 9100
- **Purpose**: System and hardware metrics
- **Resources**: Minimal (runs on all hosts)

### Visualization

**Grafana** (Dashboards and analytics)
- **Port**: 3000
- **Purpose**: Unified visualization for all data sources
- **Resources**: 2 vCPU, 4GB RAM, 40GB disk
- **Features**: Dashboards, alerts, annotations

### Enterprise Monitoring

**Zabbix Server**
- **Port**: 80 (Web), 10051 (Server)
- **Purpose**: Enterprise monitoring with SNMP, IPMI support
- **Resources**: 4 vCPU, 8GB RAM, 100GB disk
- **Database**: Built-in or external

### Log Aggregation

**Elasticsearch**
- **Port**: 9200
- **Purpose**: Centralized log storage and search
- **Resources**: 4 vCPU, 16GB RAM, 200GB disk

## Deployment Order

1. **Time-Series Database**
   - Prometheus

2. **Visualization Platform**
   - Grafana

3. **Enterprise Monitoring** (optional)
   - Zabbix Server

4. **Log Platform** (optional)
   - Elasticsearch

5. **Agents on All Hosts**
   - Node Exporter
   - Zabbix Agent

## Manual Deployment Steps

### 1. Deploy Prometheus

```bash
sudo bash /path/to/prometheus/install_prometheus.sh

# Configure scrape targets
cat > /etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# Alertmanager configuration (optional)
alerting:
  alertmanagers:
    - static_configs:
        - targets: []

# Scrape configs
scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Infrastructure hosts
  - job_name: 'infrastructure'
    static_configs:
      - targets:
          - 'host1:9100'
          - 'host2:9100'
          - 'host3:9100'
        labels:
          env: 'production'
          datacenter: 'dc1'

  # Web servers
  - job_name: 'web-servers'
    static_configs:
      - targets:
          - 'web1:9100'
          - 'web2:9100'

  # Application servers
  - job_name: 'app-servers'
    static_configs:
      - targets:
          - 'app1:9100'
          - 'app2:9100'

  # Databases
  - job_name: 'databases'
    static_configs:
      - targets:
          - 'db1:9100'
          - 'db2:9100'
EOF

sudo systemctl restart prometheus

PROMETHEUS_IP=$(hostname -I | awk '{print $1}')
echo "Prometheus: http://$PROMETHEUS_IP:9090"
```

### 2. Deploy Grafana

```bash
sudo bash /path/to/grafana/install_grafana.sh

# Wait for Grafana to start
sleep 10

# Add Prometheus as data source
curl -X POST http://admin:admin@localhost:3000/api/datasources \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Prometheus\",
    \"type\": \"prometheus\",
    \"url\": \"http://${PROMETHEUS_IP}:9090\",
    \"access\": \"proxy\",
    \"isDefault\": true
  }"

# Import Node Exporter dashboard
curl -X POST http://admin:admin@localhost:3000/api/dashboards/import \
  -H "Content-Type: application/json" \
  -d '{
    "dashboard": {
      "id": null,
      "uid": null,
      "title": "Node Exporter Full",
      "tags": ["prometheus", "node-exporter"],
      "timezone": "browser"
    },
    "overwrite": false,
    "inputs": [{
      "name": "DS_PROMETHEUS",
      "type": "datasource",
      "pluginId": "prometheus",
      "value": "Prometheus"
    }],
    "folderId": 0
  }'

GRAFANA_IP=$(hostname -I | awk '{print $1}')
echo "Grafana: http://$GRAFANA_IP:3000"
echo "Default credentials: admin/admin"
```

### 3. Deploy Zabbix Server (Optional)

```bash
sudo bash /path/to/zabbix/install_zabbix.sh

ZABBIX_IP=$(hostname -I | awk '{print $1}')
echo "Zabbix: http://$ZABBIX_IP/zabbix"
echo "Default credentials: Admin/zabbix"

# Add Zabbix data source to Grafana
curl -X POST http://admin:admin@localhost:3000/api/datasources \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Zabbix\",
    \"type\": \"alexanderzobnin-zabbix-datasource\",
    \"url\": \"http://${ZABBIX_IP}/zabbix/api_jsonrpc.php\",
    \"access\": \"proxy\",
    \"jsonData\": {
      \"username\": \"Admin\",
      \"password\": \"zabbix\"
    }
  }"
```

### 4. Deploy Elasticsearch (Optional)

```bash
sudo bash /path/to/elasticsearch/install_elasticsearch.sh

# Create index for logs
curl -X PUT "localhost:9200/applogs-$(date +%Y.%m.%d)" \
  -H 'Content-Type: application/json'

ELASTICSEARCH_IP=$(hostname -I | awk '{print $1}')
echo "Elasticsearch: http://$ELASTICSEARCH_IP:9200"

# Add Elasticsearch data source to Grafana
curl -X POST http://admin:admin@localhost:3000/api/datasources \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Elasticsearch\",
    \"type\": \"elasticsearch\",
    \"url\": \"http://${ELASTICSEARCH_IP}:9200\",
    \"access\": \"proxy\",
    \"database\": \"[applogs-]YYYY.MM.DD\",
    \"jsonData\": {
      \"timeField\": \"@timestamp\",
      \"esVersion\": \"8.0.0\"
    }
  }"
```

### 5. Deploy Node Exporter on All Hosts

```bash
# Run on each monitored host
sudo bash /path/to/node_exporter/install_node_exporter.sh

# Verify it's running
curl http://localhost:9100/metrics | head
```

## Morpheus App Blueprint

```yaml
name: "Observability Platform"
type: "morpheus"

tiers:
  monitoring:
    tierIndex: 1
    bootOrder: 1
    instances:
      - instance:
          name: "${app.name}-prometheus"
          type: "prometheus"
          plan: "2-cpu-8gb-ram"

      - instance:
          name: "${app.name}-grafana"
          type: "grafana"
          plan: "2-cpu-4gb-ram"
          environmentVariables:
            - name: "PROMETHEUS_URL"
              value: "http://${tier.monitoring.instances[0].internalIp}:9090"

  enterprise:
    tierIndex: 2
    bootOrder: 2
    instances:
      - instance:
          name: "${app.name}-zabbix"
          type: "zabbix"
          plan: "4-cpu-8gb-ram"

  logging:
    tierIndex: 3
    bootOrder: 3
    instances:
      - instance:
          name: "${app.name}-elasticsearch"
          type: "elasticsearch"
          plan: "4-cpu-16gb-ram"
```

## Post-Provisioning Workflows

### Configure Grafana Data Sources

```bash
#!/bin/bash
# Task: Configure Grafana Data Sources

PROMETHEUS_IP=$1
GRAFANA_IP=$2

# Wait for Grafana to be ready
until curl -s http://${GRAFANA_IP}:3000/api/health > /dev/null; do
  sleep 5
done

# Add Prometheus data source
curl -X POST http://admin:admin@${GRAFANA_IP}:3000/api/datasources \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Prometheus\",
    \"type\": \"prometheus\",
    \"url\": \"http://${PROMETHEUS_IP}:9090\",
    \"access\": \"proxy\",
    \"isDefault\": true
  }"

# Import default dashboards
# Node Exporter Full (ID: 1860)
curl -X POST http://admin:admin@${GRAFANA_IP}:3000/api/dashboards/import \
  -H "Content-Type: application/json" \
  -d '{"dashboard": {"id": 1860}, "overwrite": false, "folderId": 0}'
```

## Pre-configured Dashboards

### Infrastructure Dashboards

1. **Node Exporter Full** (ID: 1860)
   - System metrics
   - CPU, Memory, Disk, Network
   - Per-host breakdown

2. **Infrastructure Overview**
   - Multi-host summary
   - Resource utilization
   - Alert status

### Application Dashboards

3. **JVM Metrics** (Tomcat/Java apps)
   - Heap memory
   - Thread count
   - Garbage collection

4. **Database Performance**
   - Query rates
   - Connection pools
   - Slow queries

### Network Dashboards

5. **nginx Metrics**
   - Request rates
   - Response times
   - Error rates

## Alerting Configuration

### Prometheus Alert Rules

```yaml
# /etc/prometheus/alert.rules.yml
groups:
  - name: infrastructure
    interval: 30s
    rules:
      # High CPU usage
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% for 5 minutes"

      # High memory usage
      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 90%"

      # Disk space low
      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
          description: "Disk space is below 10%"

      # Instance down
      - alert: InstanceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} is down"
          description: "{{ $labels.job }} instance has been down for more than 1 minute"
```

### Grafana Alerts

Configure in Grafana UI:
- Threshold-based alerts
- Notification channels (email, Slack, PagerDuty)
- Alert rules per dashboard panel

## Monitoring Best Practices

### Metric Collection
- Use appropriate scrape intervals (15s default)
- Label metrics consistently
- Don't over-collect (focus on actionable metrics)

### Retention
- Adjust based on storage and query needs
- Archive old data to long-term storage
- Use downsampling for historical data

### Dashboards
- Keep dashboards focused and simple
- Use templating for multi-instance views
- Document dashboard usage

### Alerts
- Alert on symptoms, not causes
- Reduce alert fatigue
- Test alerts regularly
- Define escalation procedures

## Integration with Morpheus

### Instance Monitoring
- Automatic Node Exporter deployment on all VMs
- Morpheus-provided metrics
- Custom dashboards per application

### Cost Monitoring
- Track resource usage
- Cost per application/environment
- Showback/chargeback reports

### Governance
- Monitor policy compliance
- Track expiration timelines
- Resource utilization trends

## Testing the Platform

### 1. Verify Prometheus
```bash
# Check targets
curl http://prometheus-ip:9090/api/v1/targets

# Query metrics
curl 'http://prometheus-ip:9090/api/v1/query?query=up'
```

### 2. Verify Grafana
```bash
# Access web UI
open http://grafana-ip:3000

# Check data sources
curl http://admin:admin@grafana-ip:3000/api/datasources
```

### 3. Generate Test Metrics
```bash
# Stress test to generate CPU metrics
stress --cpu 2 --timeout 60s

# Monitor in Grafana
```

## Scaling Considerations

### Prometheus
- Federation for multi-datacenter
- Remote storage for long-term retention
- Horizontal sharding for large environments

### Grafana
- Multiple instances behind load balancer
- Shared database for configuration
- LDAP/OAuth for authentication

### Elasticsearch
- Cluster with multiple nodes
- Index lifecycle management
- Hot-warm-cold architecture

## Security

- Change all default passwords
- Enable HTTPS/SSL
- Implement authentication
- Use role-based access control
- Network segmentation
- Regular security updates

## Backup Strategy

- Prometheus data directory
- Grafana dashboards (export JSON)
- Alert rules configuration
- Data source configurations

## Next Steps

- Integrate with [3-Tier Application](../01-stack-3tier/) for app monitoring
- Monitor [Microservices](../02-microservices/) platform
- Add [High Availability](../04-ha-web/) to monitoring stack
- Implement log aggregation with ELK stack
- Add distributed tracing (Jaeger/Zipkin)
