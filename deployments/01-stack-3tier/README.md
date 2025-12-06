# 3-Tier Web Application Deployment

Complete 3-tier web application stack with web, application, and database tiers.

## Architecture Overview

```
                    ┌─────────────────┐
                    │   End Users     │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │                 │
                    │  WEB TIER       │
                    │  nginx:80       │
                    │  (Reverse Proxy)│
                    │                 │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │                 │
                    │  APP TIER       │
                    │  Tomcat:8080    │
                    │  (Java App)     │
                    │                 │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │                 │
                    │  DATABASE TIER  │
                    │  PostgreSQL:5432│
                    │  (Data Storage) │
                    │                 │
                    └─────────────────┘

         Monitoring: Prometheus + Node Exporter
```

## Components

### Tier 1: Web / Reverse Proxy
- **Service**: nginx
- **Purpose**: Reverse proxy, SSL termination, static content
- **Port**: 80 (HTTP), 443 (HTTPS optional)
- **Resources**: 1 vCPU, 2GB RAM, 20GB disk

### Tier 2: Application Server
- **Service**: Apache Tomcat
- **Purpose**: Java application runtime
- **Port**: 8080 (backend)
- **Resources**: 2 vCPU, 4GB RAM, 40GB disk

### Tier 3: Database
- **Service**: PostgreSQL
- **Purpose**: Relational database storage
- **Port**: 5432
- **Resources**: 2 vCPU, 8GB RAM, 100GB disk

### Monitoring (Optional)
- **Service**: Prometheus + Node Exporter
- **Purpose**: Metrics collection and monitoring
- **Ports**: 9090 (Prometheus), 9100 (Node Exporter)

## Deployment Order

The deployment must follow this order to properly inject variables:

1. **Database Tier** (Tier 3) - Deploy first
   - PostgreSQL installation
   - Database and user creation
   - Capture DB IP, credentials, database name

2. **Application Tier** (Tier 2) - Deploy second
   - Tomcat installation
   - Database connection configuration (using variables from Tier 3)
   - Application deployment
   - Capture App IP

3. **Web Tier** (Tier 1) - Deploy last
   - nginx installation
   - Reverse proxy configuration (using variables from Tier 2)
   - SSL configuration (optional)

4. **Monitoring** (Optional) - Deploy after all tiers
   - Prometheus installation
   - Node Exporter on all VMs
   - Target configuration

## Variable Injection

Morpheus App Blueprints automatically inject variables between tiers:

### From Database Tier → App Tier
```bash
DB_HOST=${tier3_instance_ip}
DB_PORT=5432
DB_NAME=${tier3_db_name}
DB_USER=${tier3_db_user}
DB_PASSWORD=${tier3_db_password}
```

### From App Tier → Web Tier
```bash
APP_HOST=${tier2_instance_ip}
APP_PORT=8080
```

## Manual Deployment Steps

### 1. Deploy Database Tier

```bash
# On database VM
sudo bash /path/to/postgresql/install_postgresql.sh

# Create application database
sudo -u postgres psql <<EOF
CREATE DATABASE webapp;
CREATE USER webappuser WITH PASSWORD 'SecurePassword123!';
GRANT ALL PRIVILEGES ON DATABASE webapp TO webappuser;
\q
EOF

# Configure PostgreSQL for remote connections
sudo nano /etc/postgresql/*/main/postgresql.conf
# Change: listen_addresses = '*'

sudo nano /etc/postgresql/*/main/pg_hba.conf
# Add: host    all    all    10.0.0.0/8    md5

sudo systemctl restart postgresql

# Note the database IP
DB_IP=$(hostname -I | awk '{print $1}')
echo "Database IP: $DB_IP"
```

### 2. Deploy Application Tier

```bash
# On application VM
sudo bash /path/to/tomcat/install_tomcat.sh

# Configure database connection
# Create application properties file
sudo mkdir -p /opt/tomcat/webapps/ROOT/WEB-INF/classes
sudo cat > /opt/tomcat/webapps/ROOT/WEB-INF/classes/application.properties <<EOF
db.host=<DB_IP_FROM_STEP_1>
db.port=5432
db.name=webapp
db.user=webappuser
db.password=SecurePassword123!
EOF

# Restart Tomcat
sudo systemctl restart tomcat

# Note the application IP
APP_IP=$(hostname -I | awk '{print $1}')
echo "Application IP: $APP_IP"
```

### 3. Deploy Web Tier

```bash
# On web VM
sudo bash /path/to/nginx/install_nginx.sh

# Configure reverse proxy
sudo cat > /etc/nginx/sites-available/webapp <<'EOF'
upstream app_backend {
    server <APP_IP_FROM_STEP_2>:8080;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://app_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
    }
}
EOF

# Enable the site
sudo ln -s /etc/nginx/sites-available/webapp /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

# Note the web IP
WEB_IP=$(hostname -I | awk '{print $1}')
echo "Web Tier IP: $WEB_IP"
echo "Access application at: http://$WEB_IP"
```

### 4. Deploy Monitoring (Optional)

```bash
# On monitoring VM
sudo bash /path/to/prometheus/install_prometheus.sh

# Configure targets
sudo cat > /etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'web-tier'
    static_configs:
      - targets: ['<WEB_IP>:9100']
        labels:
          tier: 'web'
          role: 'nginx'

  - job_name: 'app-tier'
    static_configs:
      - targets: ['<APP_IP>:9100']
        labels:
          tier: 'app'
          role: 'tomcat'

  - job_name: 'db-tier'
    static_configs:
      - targets: ['<DB_IP>:9100']
        labels:
          tier: 'database'
          role: 'postgresql'
EOF

sudo systemctl restart prometheus

# Install Node Exporter on each tier VM
# On web, app, and db VMs:
sudo bash /path/to/node_exporter/install_node_exporter.sh
```

## Morpheus App Blueprint

### Blueprint Structure

```yaml
name: "3-Tier Web Application"
type: "morpheus"
tiers:
  database:
    tierIndex: 1
    bootOrder: 1
    instances:
      - instance:
          type: "postgresql"
          layout: "postgresql-single"
          plan: "2-cpu-8gb-ram"
          name: "${app.name}-db"
          environmentVariables:
            - name: "DB_NAME"
              value: "webapp"
            - name: "DB_USER"
              value: "webappuser"
            - name: "DB_PASSWORD"
              value: "${cypher.read('secret/db-password')}"

  application:
    tierIndex: 2
    bootOrder: 2
    instances:
      - instance:
          type: "tomcat"
          layout: "tomcat-single"
          plan: "2-cpu-4gb-ram"
          name: "${app.name}-app"
          environmentVariables:
            - name: "DB_HOST"
              value: "${tier.database.instances[0].internalIp}"
            - name: "DB_PORT"
              value: "5432"
            - name: "DB_NAME"
              value: "${tier.database.instances[0].DB_NAME}"
            - name: "DB_USER"
              value: "${tier.database.instances[0].DB_USER}"
            - name: "DB_PASSWORD"
              value: "${tier.database.instances[0].DB_PASSWORD}"

  web:
    tierIndex: 3
    bootOrder: 3
    instances:
      - instance:
          type: "nginx"
          layout: "nginx-single"
          plan: "1-cpu-2gb-ram"
          name: "${app.name}-web"
          environmentVariables:
            - name: "BACKEND_HOST"
              value: "${tier.application.instances[0].internalIp}"
            - name: "BACKEND_PORT"
              value: "8080"
```

## Morpheus Workflows

### Post-Provision: Database Tier

```bash
#!/bin/bash
# Task: Initialize Database

# Create application database
sudo -u postgres psql <<EOF
CREATE DATABASE ${DB_NAME};
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};
EOF

# Configure for remote access
echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/*/main/postgresql.conf
echo "host    all    all    10.0.0.0/8    md5" | sudo tee -a /etc/postgresql/*/main/pg_hba.conf
sudo systemctl restart postgresql
```

### Post-Provision: Application Tier

```bash
#!/bin/bash
# Task: Configure Database Connection

# Create application properties
sudo mkdir -p /opt/tomcat/webapps/ROOT/WEB-INF/classes
sudo cat > /opt/tomcat/webapps/ROOT/WEB-INF/classes/application.properties <<EOF
db.host=${DB_HOST}
db.port=${DB_PORT}
db.name=${DB_NAME}
db.user=${DB_USER}
db.password=${DB_PASSWORD}
EOF

# Restart Tomcat
sudo systemctl restart tomcat
```

### Post-Provision: Web Tier

```bash
#!/bin/bash
# Task: Configure Reverse Proxy

# Create nginx config
sudo cat > /etc/nginx/sites-available/webapp <<EOF
upstream app_backend {
    server ${BACKEND_HOST}:${BACKEND_PORT};
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://app_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# Enable configuration
sudo ln -s /etc/nginx/sites-available/webapp /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx
```

## Testing the Deployment

### 1. Test Database Connection
```bash
# From app tier VM
psql -h <DB_IP> -U webappuser -d webapp -c "SELECT version();"
```

### 2. Test Application Tier
```bash
# Check Tomcat is running
curl http://<APP_IP>:8080
```

### 3. Test Web Tier
```bash
# Test reverse proxy
curl http://<WEB_IP>

# Test from external client
curl http://<WEB_IP>/health
```

### 4. End-to-End Test
```bash
# Access the application through the web tier
curl -v http://<WEB_IP>/
```

## Scaling Considerations

### Horizontal Scaling

**App Tier**: Add multiple Tomcat instances
- Add more instances to the application tier
- Configure session replication or sticky sessions
- Update nginx upstream configuration

**Web Tier**: Add nginx instances with HAProxy
- Deploy HAProxy in front of multiple nginx instances
- Configure health checks
- Implement SSL termination at HAProxy

### Vertical Scaling
- Increase vCPU/RAM through Morpheus plans
- Adjust JVM heap for Tomcat
- Tune PostgreSQL memory settings

## Monitoring & Alerts

### Key Metrics to Monitor

**Web Tier**:
- HTTP request rate
- Response time
- Error rate (4xx, 5xx)
- Active connections

**App Tier**:
- JVM heap usage
- Thread count
- Request processing time
- Database connection pool

**Database Tier**:
- Connection count
- Query performance
- Disk I/O
- Replication lag (if applicable)

### Grafana Dashboards

Import these dashboards:
- **nginx**: Dashboard ID 12708
- **Tomcat**: Dashboard ID 10728
- **PostgreSQL**: Dashboard ID 9628

## Security Considerations

- Change all default passwords
- Enable SSL/TLS on nginx
- Configure PostgreSQL SSL connections
- Use security groups/firewall rules
- Implement application-level authentication
- Regular security updates
- Database backup strategy

## Cost Optimization

### Development Environment
- Smaller plans (1 vCPU, 2GB RAM per tier)
- Single instances
- Auto-shutdown policies
- 30-day expiration

### Production Environment
- Appropriate sizing based on load
- Multiple instances for HA
- Backup policies
- No expiration
- Monitoring enabled

## Troubleshooting

### Common Issues

**Database connection refused**:
- Check PostgreSQL is listening on all interfaces
- Verify pg_hba.conf allows connection from app tier IP
- Check firewall rules

**502 Bad Gateway from nginx**:
- Verify Tomcat is running on app tier
- Check upstream configuration in nginx
- Verify network connectivity between tiers

**Application errors**:
- Check Tomcat logs: `/opt/tomcat/logs/catalina.out`
- Verify database connection string
- Check environment variables

## Next Steps

- Deploy [Microservices Stack](../02-microservices/) for more complex scenarios
- Add [Observability Platform](../03-observability/) for comprehensive monitoring
- Implement [High Availability](../04-ha-web/) patterns for production
