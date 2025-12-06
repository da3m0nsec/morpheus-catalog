# Modern Microservices Stack Deployment

Complete microservices platform with API gateway, multiple services, message queue, caching, and monitoring.

## Architecture Overview

```
                          ┌──────────────┐
                          │  End Users   │
                          └──────┬───────┘
                                 │
                        ┌────────▼────────┐
                        │  API GATEWAY    │
                        │  nginx:80       │
                        │  (Routing)      │
                        └────────┬────────┘
                                 │
                 ┌───────────────┼───────────────┐
                 │               │               │
        ┌────────▼────────┐ ┌───▼─────┐ ┌──────▼──────┐
        │  USER SERVICE   │ │ PRODUCT │ │ ORDER       │
        │  Tomcat:8081    │ │ SERVICE │ │ SERVICE     │
        │                 │ │ :8082   │ │ :8083       │
        └────────┬────────┘ └───┬─────┘ └──────┬──────┘
                 │              │               │
                 ├──────────────┴───────────────┤
                 │                              │
        ┌────────▼────────┐          ┌─────────▼──────┐
        │  MongoDB:27017  │          │ RabbitMQ:5672  │
        │  (NoSQL DB)     │          │ (Message Queue)│
        └─────────────────┘          └────────────────┘
                 │
        ┌────────▼────────┐
        │  Redis:6379     │
        │  (Cache)        │
        └─────────────────┘

      Monitoring: Prometheus + Grafana
```

## Components

### API Gateway
- **Service**: nginx
- **Purpose**: API routing, load balancing, rate limiting
- **Port**: 80
- **Resources**: 2 vCPU, 4GB RAM, 20GB disk

### Microservices (3 instances)

**User Service**
- **Service**: Tomcat
- **Port**: 8081
- **Database**: MongoDB (users collection)
- **Cache**: Redis
- **Resources**: 2 vCPU, 4GB RAM, 40GB disk

**Product Service**
- **Service**: Tomcat
- **Port**: 8082
- **Database**: MongoDB (products collection)
- **Cache**: Redis
- **Resources**: 2 vCPU, 4GB RAM, 40GB disk

**Order Service**
- **Service**: Tomcat
- **Port**: 8083
- **Database**: MongoDB (orders collection)
- **Messaging**: RabbitMQ
- **Resources**: 2 vCPU, 4GB RAM, 40GB disk

### Data Layer

**MongoDB**
- **Purpose**: Primary data store for all services
- **Port**: 27017
- **Resources**: 4 vCPU, 16GB RAM, 200GB disk

**Redis**
- **Purpose**: Distributed cache, session storage
- **Port**: 6379
- **Resources**: 2 vCPU, 8GB RAM, 20GB disk

**RabbitMQ**
- **Purpose**: Async messaging, event-driven communication
- **Ports**: 5672 (AMQP), 15672 (Management)
- **Resources**: 2 vCPU, 4GB RAM, 40GB disk

### Monitoring

**Prometheus**
- **Port**: 9090
- **Resources**: 2 vCPU, 8GB RAM, 100GB disk

**Grafana**
- **Port**: 3000
- **Resources**: 1 vCPU, 2GB RAM, 20GB disk

## Deployment Order

1. **Data Layer** (parallel deployment)
   - MongoDB
   - Redis
   - RabbitMQ

2. **Microservices** (after data layer)
   - User Service
   - Product Service
   - Order Service

3. **API Gateway** (after microservices)
   - nginx with routing configuration

4. **Monitoring** (optional, can be last)
   - Prometheus
   - Grafana

## Service Communication Patterns

### Synchronous (REST/HTTP)
- API Gateway → Microservices
- Service-to-Service calls (when needed)

### Asynchronous (Message Queue)
- Order Service → RabbitMQ → Order Processing
- Event-driven notifications

### Caching Strategy
- Read-through cache for frequently accessed data
- Cache invalidation on updates
- Session storage for user sessions

## API Gateway Configuration

### nginx Routes

```nginx
# User Service
location /api/users {
    proxy_pass http://user-service:8081;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}

# Product Service
location /api/products {
    proxy_pass http://product-service:8082;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}

# Order Service
location /api/orders {
    proxy_pass http://order-service:8083;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}

# Rate Limiting
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
limit_req zone=api_limit burst=20 nodelay;
```

## Manual Deployment Steps

### 1. Deploy Data Layer

**MongoDB**:
```bash
sudo bash /path/to/mongodb/install_mongodb.sh

# Create databases and collections
mongosh <<EOF
use usersdb
db.createCollection("users")
use productsdb
db.createCollection("products")
use ordersdb
db.createCollection("orders")
EOF

MONGODB_IP=$(hostname -I | awk '{print $1}')
echo "MongoDB IP: $MONGODB_IP"
```

**Redis**:
```bash
sudo bash /path/to/redis/install_redis.sh

# Configure for remote access
sudo sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf
sudo systemctl restart redis

REDIS_IP=$(hostname -I | awk '{print $1}')
echo "Redis IP: $REDIS_IP"
```

**RabbitMQ**:
```bash
sudo bash /path/to/rabbitmq/install_rabbitmq.sh

# Create queues
sudo rabbitmqctl add_vhost microservices
sudo rabbitmqctl set_permissions -p microservices admin ".*" ".*" ".*"

RABBITMQ_IP=$(hostname -I | awk '{print $1}')
echo "RabbitMQ IP: $RABBITMQ_IP"
```

### 2. Deploy Microservices

**User Service** (Port 8081):
```bash
sudo bash /path/to/tomcat/install_tomcat.sh

# Configure service
sudo mkdir -p /opt/tomcat/conf/Catalina/localhost
cat > /opt/tomcat/conf/Catalina/localhost/application.properties <<EOF
service.name=user-service
service.port=8081
mongodb.uri=mongodb://${MONGODB_IP}:27017/usersdb
redis.host=${REDIS_IP}
redis.port=6379
EOF

# Change Tomcat port
sudo sed -i 's/8080/8081/' /opt/tomcat/conf/server.xml
sudo systemctl restart tomcat

USER_SERVICE_IP=$(hostname -I | awk '{print $1}')
```

**Product Service** (Port 8082):
```bash
# Similar to User Service, but port 8082 and productsdb
sudo sed -i 's/8080/8082/' /opt/tomcat/conf/server.xml
```

**Order Service** (Port 8083):
```bash
# Similar to User Service, but includes RabbitMQ config
cat > /opt/tomcat/conf/Catalina/localhost/application.properties <<EOF
service.name=order-service
service.port=8083
mongodb.uri=mongodb://${MONGODB_IP}:27017/ordersdb
redis.host=${REDIS_IP}
redis.port=6379
rabbitmq.host=${RABBITMQ_IP}
rabbitmq.port=5672
rabbitmq.vhost=microservices
rabbitmq.user=admin
rabbitmq.password=admin
EOF

sudo sed -i 's/8080/8083/' /opt/tomcat/conf/server.xml
```

### 3. Deploy API Gateway

```bash
sudo bash /path/to/nginx/install_nginx.sh

# Configure routing
cat > /etc/nginx/sites-available/api-gateway <<EOF
upstream user_service {
    server ${USER_SERVICE_IP}:8081;
}

upstream product_service {
    server ${PRODUCT_SERVICE_IP}:8082;
}

upstream order_service {
    server ${ORDER_SERVICE_IP}:8083;
}

# Rate limiting
limit_req_zone \$binary_remote_addr zone=api_limit:10m rate=10r/s;

server {
    listen 80;
    server_name _;

    # Rate limiting
    limit_req zone=api_limit burst=20 nodelay;

    # User Service
    location /api/users {
        proxy_pass http://user_service;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # Product Service
    location /api/products {
        proxy_pass http://product_service;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    # Order Service
    location /api/orders {
        proxy_pass http://order_service;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    # Health check
    location /health {
        access_log off;
        return 200 "healthy\n";
    }

    # API Documentation
    location / {
        return 200 '{"services": ["users", "products", "orders"], "version": "1.0"}';
        add_header Content-Type application/json;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/api-gateway /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

### 4. Deploy Monitoring

**Prometheus**:
```bash
sudo bash /path/to/prometheus/install_prometheus.sh

# Configure targets
cat > /etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'api-gateway'
    static_configs:
      - targets: ['${GATEWAY_IP}:9100']

  - job_name: 'user-service'
    static_configs:
      - targets: ['${USER_SERVICE_IP}:9100']

  - job_name: 'product-service'
    static_configs:
      - targets: ['${PRODUCT_SERVICE_IP}:9100']

  - job_name: 'order-service'
    static_configs:
      - targets: ['${ORDER_SERVICE_IP}:9100']

  - job_name: 'mongodb'
    static_configs:
      - targets: ['${MONGODB_IP}:9100']

  - job_name: 'redis'
    static_configs:
      - targets: ['${REDIS_IP}:9100']

  - job_name: 'rabbitmq'
    static_configs:
      - targets: ['${RABBITMQ_IP}:15692']
EOF

sudo systemctl restart prometheus
```

**Grafana**:
```bash
sudo bash /path/to/grafana/install_grafana.sh

# Add Prometheus as data source (via API)
curl -X POST http://admin:admin@localhost:3000/api/datasources \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://localhost:9090",
    "access": "proxy"
  }'
```

## Morpheus App Blueprint

```yaml
name: "Microservices Platform"
type: "morpheus"

tiers:
  data:
    tierIndex: 1
    bootOrder: 1
    instances:
      - instance:
          name: "${app.name}-mongodb"
          type: "mongodb"
          plan: "4-cpu-16gb-ram"
      - instance:
          name: "${app.name}-redis"
          type: "redis"
          plan: "2-cpu-8gb-ram"
      - instance:
          name: "${app.name}-rabbitmq"
          type: "rabbitmq"
          plan: "2-cpu-4gb-ram"

  services:
    tierIndex: 2
    bootOrder: 2
    instances:
      - instance:
          name: "${app.name}-user-svc"
          type: "tomcat"
          plan: "2-cpu-4gb-ram"
          environmentVariables:
            - name: "SERVICE_PORT"
              value: "8081"
            - name: "MONGODB_URI"
              value: "mongodb://${tier.data.instances[0].internalIp}:27017/usersdb"
            - name: "REDIS_HOST"
              value: "${tier.data.instances[1].internalIp}"

      - instance:
          name: "${app.name}-product-svc"
          type: "tomcat"
          plan: "2-cpu-4gb-ram"
          environmentVariables:
            - name: "SERVICE_PORT"
              value: "8082"
            - name: "MONGODB_URI"
              value: "mongodb://${tier.data.instances[0].internalIp}:27017/productsdb"

      - instance:
          name: "${app.name}-order-svc"
          type: "tomcat"
          plan: "2-cpu-4gb-ram"
          environmentVariables:
            - name: "SERVICE_PORT"
              value: "8083"
            - name: "RABBITMQ_HOST"
              value: "${tier.data.instances[2].internalIp}"

  gateway:
    tierIndex: 3
    bootOrder: 3
    instances:
      - instance:
          name: "${app.name}-gateway"
          type: "nginx"
          plan: "2-cpu-4gb-ram"
          environmentVariables:
            - name: "USER_SERVICE"
              value: "${tier.services.instances[0].internalIp}:8081"
            - name: "PRODUCT_SERVICE"
              value: "${tier.services.instances[1].internalIp}:8082"
            - name: "ORDER_SERVICE"
              value: "${tier.services.instances[2].internalIp}:8083"
```

## Testing the Deployment

### API Endpoints

```bash
GATEWAY_IP=<your-gateway-ip>

# Health check
curl http://$GATEWAY_IP/health

# User Service
curl -X POST http://$GATEWAY_IP/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'

curl http://$GATEWAY_IP/api/users

# Product Service
curl -X POST http://$GATEWAY_IP/api/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Product 1", "price": 99.99}'

curl http://$GATEWAY_IP/api/products

# Order Service
curl -X POST http://$GATEWAY_IP/api/orders \
  -H "Content-Type: application/json" \
  -d '{"userId": 1, "productId": 1, "quantity": 2}'

curl http://$GATEWAY_IP/api/orders
```

## Scaling Strategies

### Horizontal Scaling

**Microservices**: Add more instances per service
- Load balance with nginx upstream
- Stateless design allows easy scaling
- Share cache (Redis) and database (MongoDB)

**Data Layer**: Scale MongoDB with replication
- Configure replica sets
- Read replicas for read-heavy services

### Auto-Scaling

Configure Morpheus auto-scaling policies:
- CPU threshold: 70%
- Memory threshold: 80%
- Min instances: 1
- Max instances: 5

## Monitoring & Observability

### Key Metrics

**API Gateway**:
- Request rate per service
- Response time distribution
- Error rates (4xx, 5xx)
- Rate limit hits

**Microservices**:
- Request latency
- Database query time
- Cache hit/miss ratio
- Message queue depth

**Data Layer**:
- MongoDB operations/sec
- Redis memory usage
- RabbitMQ queue length

### Distributed Tracing

Consider adding:
- Jaeger for distributed tracing
- Correlation IDs across services
- Request flow visualization

## Security Considerations

- API authentication (JWT tokens)
- Service-to-service authentication
- Secrets management for credentials
- Network segmentation
- Rate limiting and DDoS protection
- Input validation
- MongoDB authentication
- RabbitMQ user permissions

## Disaster Recovery

- MongoDB regular backups
- Redis persistence configuration
- RabbitMQ message durability
- Infrastructure as Code
- Blue-green deployments
- Canary releases

## Cost Optimization

### Development
- Single instance per service
- Smaller resource plans
- Auto-shutdown after hours

### Production
- Right-size based on metrics
- Use auto-scaling
- Reserved capacity for base load
- Spot instances for burst capacity

## Next Steps

- Implement [Observability Platform](../03-observability/) for enhanced monitoring
- Add [High Availability](../04-ha-web/) patterns for production readiness
- Integrate CI/CD pipelines with Morpheus
- Implement service mesh (Istio/Linkerd)
