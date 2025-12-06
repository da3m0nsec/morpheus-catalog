# Elasticsearch Installation and Configuration

This directory contains scripts and documentation for installing and configuring Elasticsearch.

## Contents

- `install_elasticsearch.sh` - Installation script for Elasticsearch

## Installation

Run the installation script:

```bash
bash install_elasticsearch.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges
- Minimum 4GB RAM recommended
- Java (installed automatically)

## Features

- Automated installation of Elasticsearch
- Java installation
- Security configuration
- Service management
- Memory optimization

## Usage

After installation, Elasticsearch will be available as a system service:

```bash
# Start Elasticsearch
sudo systemctl start elasticsearch

# Stop Elasticsearch
sudo systemctl stop elasticsearch

# Check status
sudo systemctl status elasticsearch

# Enable on boot
sudo systemctl enable elasticsearch

# View logs
sudo journalctl -u elasticsearch -f
```

## Configuration

Elasticsearch configuration files are located at:
- `/etc/elasticsearch/elasticsearch.yml` - Main configuration
- `/etc/elasticsearch/jvm.options` - JVM settings
- `/var/lib/elasticsearch/` - Data directory
- `/var/log/elasticsearch/` - Log directory

## Default Access

- HTTP port: `9200`
- Transport port: `9300`
- Default URL: `http://localhost:9200`

## Testing the Installation

```bash
# Check cluster health
curl -X GET "localhost:9200/_cluster/health?pretty"

# Get cluster info
curl -X GET "localhost:9200/"

# List all indices
curl -X GET "localhost:9200/_cat/indices?v"

# Check nodes
curl -X GET "localhost:9200/_cat/nodes?v"
```

## Basic Operations

### Create an Index
```bash
curl -X PUT "localhost:9200/myindex"
```

### Index a Document
```bash
curl -X POST "localhost:9200/myindex/_doc/1" -H 'Content-Type: application/json' -d'
{
  "title": "Test Document",
  "content": "This is a test"
}
'
```

### Search Documents
```bash
curl -X GET "localhost:9200/myindex/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "content": "test"
    }
  }
}
'
```

### Delete an Index
```bash
curl -X DELETE "localhost:9200/myindex"
```

## Memory Configuration

Edit `/etc/elasticsearch/jvm.options`:

```
# Set heap size (recommended: 50% of RAM, max 32GB)
-Xms2g
-Xmx2g
```

## Main Configuration

Edit `/etc/elasticsearch/elasticsearch.yml`:

```yaml
# Cluster name
cluster.name: my-cluster

# Node name
node.name: node-1

# Network settings
network.host: 0.0.0.0
http.port: 9200

# Discovery settings
discovery.type: single-node

# Path settings
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
```

## Security Configuration

Elasticsearch 8.x has security enabled by default. Credentials are generated during installation.

### Reset Password
```bash
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
```

### Create User
```bash
sudo /usr/share/elasticsearch/bin/elasticsearch-users useradd myuser -p mypassword -r superuser
```

## Monitoring

### Cluster Health
```bash
curl -X GET "localhost:9200/_cluster/health?pretty"
```

### Node Statistics
```bash
curl -X GET "localhost:9200/_nodes/stats?pretty"
```

### Index Statistics
```bash
curl -X GET "localhost:9200/_stats?pretty"
```

## Integration with Kibana

Install Kibana to visualize Elasticsearch data:
- Kibana port: `5601`
- Configure `elasticsearch.hosts` in `/etc/kibana/kibana.yml`

## Integration with Logstash

Use Logstash to ingest data into Elasticsearch:
- Configure output to Elasticsearch in Logstash pipeline
- Set `hosts => ["localhost:9200"]`

## Performance Tuning

### Disable Swapping
```bash
sudo swapoff -a
```

Edit `/etc/fstab` and comment out swap entries.

### Increase File Descriptors
Edit `/etc/security/limits.conf`:
```
elasticsearch soft nofile 65536
elasticsearch hard nofile 65536
```

### Increase Virtual Memory
```bash
sudo sysctl -w vm.max_map_count=262144
```

Make permanent in `/etc/sysctl.conf`:
```
vm.max_map_count=262144
```

## Backup and Restore

### Create Snapshot Repository
```bash
curl -X PUT "localhost:9200/_snapshot/my_backup" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/mount/backups/my_backup"
  }
}
'
```

### Create Snapshot
```bash
curl -X PUT "localhost:9200/_snapshot/my_backup/snapshot_1?wait_for_completion=true"
```

### Restore Snapshot
```bash
curl -X POST "localhost:9200/_snapshot/my_backup/snapshot_1/_restore"
```

## Clustering

For production, configure multiple nodes:

```yaml
# Node 1
cluster.name: production-cluster
node.name: node-1
discovery.seed_hosts: ["node1-ip", "node2-ip", "node3-ip"]
cluster.initial_master_nodes: ["node-1", "node-2", "node-3"]

# Node 2
cluster.name: production-cluster
node.name: node-2
discovery.seed_hosts: ["node1-ip", "node2-ip", "node3-ip"]
cluster.initial_master_nodes: ["node-1", "node-2", "node-3"]
```

## Security Best Practices

- Enable security features (enabled by default in 8.x)
- Use strong passwords
- Enable TLS/SSL for HTTP and transport
- Configure role-based access control (RBAC)
- Regular backups
- Keep Elasticsearch updated
- Monitor cluster health
- Limit network exposure
- Use firewall rules

## Common Issues

### Service won't start
Check logs:
```bash
sudo journalctl -u elasticsearch -n 50
```

### Out of memory
Adjust JVM heap size in `/etc/elasticsearch/jvm.options`

### Port already in use
```bash
sudo netstat -tulpn | grep 9200
```

## Useful Resources

- Elasticsearch Documentation: https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html
- Elasticsearch APIs: https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html
- Performance Tuning: https://www.elastic.co/guide/en/elasticsearch/reference/current/tune-for-indexing-speed.html
