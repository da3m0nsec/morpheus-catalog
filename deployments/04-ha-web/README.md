# High Availability Web Application Deployment

Production-ready high availability web application with load balancing, redundancy, failover, and monitoring.

## Architecture Overview

```
                      ┌──────────────┐
                      │  End Users   │
                      └──────┬───────┘
                             │
                    ┌────────▼────────┐
                    │  Virtual IP     │
                    │  (Keepalived)   │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
     ┌────────▼────────┐          ┌────────▼────────┐
     │  HAProxy 1      │          │  HAProxy 2      │
     │  (Primary)      │◄────────►│  (Backup)       │
     │  :80, :443      │  VRRP    │  :80, :443      │
     └────────┬────────┘          └────────┬────────┘
              │                             │
              └──────────────┬──────────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
  ┌──────▼──────┐     ┌──────▼──────┐     ┌──────▼──────┐
  │  nginx 1    │     │  nginx 2    │     │  nginx 3    │
  │  :80        │     │  :80        │     │  :80        │
  └──────┬──────┘     └──────┬──────┘     └──────┬──────┘
         │                   │                   │
         └───────────────────┼───────────────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
     ┌────────▼────────┐          ┌────────▼────────┐
     │  PostgreSQL 1   │          │  PostgreSQL 2   │
     │  (Primary)      │◄────────►│  (Replica)      │
     │  :5432          │  Replica │  :5432          │
     └─────────────────┘          └─────────────────┘

            Monitoring: Prometheus + Grafana
```

## Components

### Load Balancer Layer (Active/Passive)

**HAProxy Primary**
- **Port**: 80 (HTTP), 443 (HTTPS)
- **Purpose**: Primary load balancer
- **Resources**: 2 vCPU, 4GB RAM, 40GB disk

**HAProxy Backup**
- **Port**: 80 (HTTP), 443 (HTTPS)
- **Purpose**: Failover load balancer
- **Resources**: 2 vCPU, 4GB RAM, 40GB disk

**Keepalived** (on both HAProxy instances)
- **Purpose**: Virtual IP management, failover
- **Protocol**: VRRP

### Web Server Layer (Active/Active)

**nginx Instance 1, 2, 3**
- **Port**: 80
- **Purpose**: Redundant web servers
- **Resources**: 2 vCPU, 4GB RAM, 40GB disk each
- **Load Distribution**: Round-robin

### Database Layer (Primary/Replica)

**PostgreSQL Primary**
- **Port**: 5432
- **Purpose**: Primary database (read/write)
- **Resources**: 4 vCPU, 16GB RAM, 200GB disk

**PostgreSQL Replica**
- **Port**: 5432
- **Purpose**: Read replica, failover candidate
- **Resources**: 4 vCPU, 16GB RAM, 200GB disk
- **Replication**: Streaming replication

### Monitoring

**Prometheus + Grafana**
- Health checks and metrics
- Failover detection
- Performance monitoring

## High Availability Features

### Load Balancer HA
- **Active/Passive** configuration
- **Virtual IP** shared between HAProxy instances
- **VRRP** automatic failover (< 3 seconds)
- **Health checks** for backend servers

### Web Server HA
- **Active/Active** configuration
- **N+1 redundancy** (3 servers, 2 required minimum)
- **Automatic removal** of failed instances
- **Session persistence** (sticky sessions or shared storage)

### Database HA
- **Streaming replication** for data redundancy
- **Automatic failover** with pg_auto_failover or Patroni
- **Read scaling** with replica
- **Point-in-time recovery**

## Deployment Order

1. **Database Layer** (with replication)
   - PostgreSQL Primary
   - PostgreSQL Replica
   - Configure streaming replication

2. **Web Server Layer**
   - nginx instances (3x)
   - Deploy identical configurations

3. **Load Balancer Layer**
   - HAProxy Primary
   - HAProxy Backup
   - Configure Keepalived
   - Set up Virtual IP

4. **Monitoring** (after all components)
   - Prometheus
   - Grafana

## Manual Deployment Steps

### 1. Deploy PostgreSQL Primary

```bash
# On primary database server
sudo bash /path/to/postgresql/install_postgresql.sh

# Configure for replication
sudo -u postgres psql <<EOF
CREATE ROLE replicator WITH REPLICATION PASSWORD 'replicator_password' LOGIN;
EOF

# Edit postgresql.conf
cat >> /etc/postgresql/*/main/postgresql.conf <<EOF
listen_addresses = '*'
wal_level = replica
max_wal_senders = 3
wal_keep_size = 64
EOF

# Edit pg_hba.conf
cat >> /etc/postgresql/*/main/pg_hba.conf <<EOF
host replication replicator 0.0.0.0/0 md5
host all all 0.0.0.0/0 md5
EOF

sudo systemctl restart postgresql

PRIMARY_DB_IP=$(hostname -I | awk '{print $1}')
echo "Primary DB IP: $PRIMARY_DB_IP"
```

### 2. Deploy PostgreSQL Replica

```bash
# On replica database server
sudo bash /path/to/postgresql/install_postgresql.sh

# Stop PostgreSQL
sudo systemctl stop postgresql

# Remove existing data
sudo rm -rf /var/lib/postgresql/*/main/*

# Copy data from primary
sudo -u postgres pg_basebackup -h ${PRIMARY_DB_IP} -D /var/lib/postgresql/*/main -U replicator -P -v -R

# Start replica
sudo systemctl start postgresql

REPLICA_DB_IP=$(hostname -I | awk '{print $1}')
echo "Replica DB IP: $REPLICA_DB_IP"

# Verify replication
sudo -u postgres psql -c "SELECT * FROM pg_stat_replication;"
```

### 3. Deploy nginx Web Servers (3 instances)

```bash
# On each nginx server
sudo bash /path/to/nginx/install_nginx.sh

# Create identical configuration
cat > /etc/nginx/sites-available/app <<'EOF'
server {
    listen 80;
    server_name _;

    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Create test page with server identifier
HOSTNAME=$(hostname)
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>HA Web Application</title></head>
<body>
    <h1>High Availability Web Application</h1>
    <p>Served by: <strong>$HOSTNAME</strong></p>
    <p>Time: $(date)</p>
</body>
</html>
EOF

sudo nginx -t
sudo systemctl reload nginx

WEB_IP=$(hostname -I | awk '{print $1}')
echo "Web Server IP: $WEB_IP"
```

### 4. Deploy HAProxy Primary

```bash
# On HAProxy primary server
sudo bash /path/to/haproxy/install_haproxy.sh

# Configure HAProxy
cat > /etc/haproxy/haproxy.cfg <<EOF
global
    log /dev/log local0
    maxconn 4096
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000

# Statistics page
listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
    stats auth admin:admin

# Frontend
frontend http_front
    bind *:80
    default_backend web_servers

# Backend with health checks
backend web_servers
    balance roundrobin
    option httpchk GET /health
    http-check expect status 200

    server web1 ${WEB1_IP}:80 check inter 2000 rise 2 fall 3
    server web2 ${WEB2_IP}:80 check inter 2000 rise 2 fall 3
    server web3 ${WEB3_IP}:80 check inter 2000 rise 2 fall 3
EOF

sudo systemctl restart haproxy

HAPROXY1_IP=$(hostname -I | awk '{print $1}')
echo "HAProxy Primary IP: $HAPROXY1_IP"
```

### 5. Deploy HAProxy Backup (identical configuration)

```bash
# Same configuration as HAProxy Primary
HAPROXY2_IP=$(hostname -I | awk '{print $1}')
echo "HAProxy Backup IP: $HAPROXY2_IP"
```

### 6. Configure Keepalived (on both HAProxy servers)

```bash
# Install Keepalived
sudo apt-get update
sudo apt-get install -y keepalived

# On HAProxy PRIMARY
cat > /etc/keepalived/keepalived.conf <<EOF
vrrp_script chk_haproxy {
    script "/usr/bin/killall -0 haproxy"
    interval 2
    weight 2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 101
    advert_int 1

    authentication {
        auth_type PASS
        auth_pass SecurePassword123
    }

    virtual_ipaddress {
        ${VIRTUAL_IP}/24
    }

    track_script {
        chk_haproxy
    }
}
EOF

# On HAProxy BACKUP (same but state=BACKUP, priority=100)
# ...

sudo systemctl enable keepalived
sudo systemctl start keepalived

echo "Virtual IP: $VIRTUAL_IP"
```

### 7. Deploy Monitoring

```bash
# Prometheus configuration
cat > /etc/prometheus/prometheus.yml <<EOF
scrape_configs:
  - job_name: 'haproxy'
    static_configs:
      - targets:
          - '${HAPROXY1_IP}:9100'
          - '${HAPROXY2_IP}:9100'

  - job_name: 'web-servers'
    static_configs:
      - targets:
          - '${WEB1_IP}:9100'
          - '${WEB2_IP}:9100'
          - '${WEB3_IP}:9100'

  - job_name: 'databases'
    static_configs:
      - targets:
          - '${PRIMARY_DB_IP}:9100'
          - '${REPLICA_DB_IP}:9100'
EOF
```

## Morpheus App Blueprint

```yaml
name: "HA Web Application"
type: "morpheus"

tiers:
  database:
    tierIndex: 1
    bootOrder: 1
    instances:
      - instance:
          name: "${app.name}-db-primary"
          type: "postgresql"
          plan: "4-cpu-16gb-ram"
          environmentVariables:
            - name: "ROLE"
              value: "primary"

      - instance:
          name: "${app.name}-db-replica"
          type: "postgresql"
          plan: "4-cpu-16gb-ram"
          environmentVariables:
            - name: "ROLE"
              value: "replica"
            - name: "PRIMARY_IP"
              value: "${tier.database.instances[0].internalIp}"

  web:
    tierIndex: 2
    bootOrder: 2
    instanceCount: 3
    instances:
      - instance:
          name: "${app.name}-web-${sequence}"
          type: "nginx"
          plan: "2-cpu-4gb-ram"
          count: 3

  loadbalancer:
    tierIndex: 3
    bootOrder: 3
    instances:
      - instance:
          name: "${app.name}-lb-primary"
          type: "haproxy"
          plan: "2-cpu-4gb-ram"
          environmentVariables:
            - name: "WEB_SERVERS"
              value: "${tier.web.instances[*].internalIp}"
            - name: "VIRTUAL_IP"
              value: "${customOptions.virtualIp}"
            - name: "ROLE"
              value: "MASTER"

      - instance:
          name: "${app.name}-lb-backup"
          type: "haproxy"
          plan: "2-cpu-4gb-ram"
          environmentVariables:
            - name: "WEB_SERVERS"
              value: "${tier.web.instances[*].internalIp}"
            - name: "VIRTUAL_IP"
              value: "${customOptions.virtualIp}"
            - name: "ROLE"
              value: "BACKUP"
```

## Failover Testing

### Test Load Balancer Failover

```bash
# Check which HAProxy is active
ip addr show | grep ${VIRTUAL_IP}

# Stop primary HAProxy
sudo systemctl stop haproxy

# Verify backup takes over (within 3 seconds)
ping -c 5 ${VIRTUAL_IP}

# Restart primary
sudo systemctl start haproxy
```

### Test Web Server Failover

```bash
# Stop one nginx instance
sudo systemctl stop nginx

# Verify traffic routes to other servers
watch -n 1 "curl http://${VIRTUAL_IP}"

# Check HAProxy stats
curl http://${HAPROXY_IP}:8404/stats
```

### Test Database Failover

```bash
# Promote replica to primary (manual failover)
sudo -u postgres /usr/lib/postgresql/*/bin/pg_ctl promote -D /var/lib/postgresql/*/main

# Verify replication status
sudo -u postgres psql -c "SELECT * FROM pg_stat_replication;"
```

## Monitoring & Alerts

### Key Metrics

**Load Balancer**:
- Active backend servers
- Request rate
- Error rate
- Failover events

**Web Servers**:
- Health check status
- Request distribution
- Response times

**Database**:
- Replication lag
- Connection count
- Query performance

### Critical Alerts

- HAProxy failover event
- Web server down
- Database replication lag > 10s
- All web servers down
- Database primary down

## Capacity Planning

### Sizing Guidelines

**Minimum for HA**:
- 2 load balancers
- 3 web servers
- 2 database servers

**Production Recommendation**:
- 2 load balancers (active/passive)
- 4-6 web servers (active/active)
- 3 database servers (1 primary, 2 replicas)

### Scaling Strategies

**Vertical Scaling**:
- Increase vCPU/RAM per instance
- Upgrade to faster storage

**Horizontal Scaling**:
- Add more web servers (easy)
- Add more read replicas (database)
- Geographic distribution

## Disaster Recovery

### Backup Strategy
- Database: Daily full + continuous WAL archiving
- Configuration: Version control all configs
- Application: Store in artifact repository

### Recovery Objectives
- **RTO** (Recovery Time Objective): < 15 minutes
- **RPO** (Recovery Point Objective): < 5 minutes

### DR Procedures
1. Database recovery from backup
2. Promote replica to primary
3. Restore web servers from golden image
4. Update load balancer configuration

## Security Considerations

- SSL/TLS termination at load balancer
- Firewall rules between tiers
- Database encryption in transit
- Regular security updates
- DDoS protection
- Rate limiting
- Web Application Firewall (WAF)

## Cost Optimization

### Production
- Right-size based on actual usage
- Use committed instances for base load
- Auto-scaling for peak traffic
- Reserved capacity for databases

### Development/Testing
- Reduced instance counts (1 LB, 2 web, 1 DB)
- Smaller resource plans
- Auto-shutdown policies

## Performance Tuning

### HAProxy
```
maxconn 10000
nbproc 4  # CPU cores
```

### nginx
```
worker_processes auto;
worker_connections 4096;
keepalive_timeout 65;
```

### PostgreSQL
```
shared_buffers = 4GB
effective_cache_size = 12GB
max_connections = 200
```

## Next Steps

- Implement [Observability Platform](../03-observability/) for comprehensive monitoring
- Add [Microservices](../02-microservices/) architecture patterns
- Implement blue-green deployments
- Add geographic redundancy
- Implement automated failover testing
- Set up disaster recovery site
