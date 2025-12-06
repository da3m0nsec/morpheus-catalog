# Morpheus Catalog - Service Installation Scripts & Deployment Examples

Comprehensive catalog of service installation scripts and deployment architectures for HPE Morpheus PoC demonstrations with VMware on-premises and HVM infrastructure.

## Overview

This repository provides:
- **17 automated service installation scripts** for popular infrastructure and application services
- **4 complete deployment architectures** demonstrating multi-tier applications and HA patterns
- **Production-ready configurations** for enterprise environments
- **Morpheus App Blueprint examples** for automated provisioning
- **Security best practices** and monitoring integration

## Repository Structure

```
morpheus-catalog/
├── installs/              # Service installation scripts (17 services)
│   ├── nginx/                   # Web server and reverse proxy
│   ├── apache/                  # Apache HTTP Server
│   ├── haproxy/                 # Load balancer
│   ├── tomcat/                  # Java application server
│   ├── postgresql/              # Relational database
│   ├── mongodb/                 # NoSQL document database
│   ├── mysql/                   # MySQL/MariaDB relational database
│   ├── redis/                   # In-memory data store
│   ├── elasticsearch/           # Search and analytics engine
│   ├── prometheus/              # Metrics collection and monitoring
│   ├── node_exporter/           # System metrics exporter
│   ├── grafana/                 # Visualization and dashboards
│   ├── zabbix/                  # Enterprise monitoring solution
│   ├── rabbitmq/                # Message broker
│   └── docker/                  # Container platform
│
├── deployments/           # Complete VM-based deployment architectures
│   ├── stack-3tier/             # 3-Tier web application
│   ├── microservices/           # Modern microservices platform
│   ├── observability/           # Monitoring and observability stack
│   └── ha-web/                  # High availability web application
│
├── kubernetes/            # Kubernetes deployment examples
│   ├── simple-webapp/           # Simple web application
│   ├── 3tier-k8s/               # 3-tier on Kubernetes
│   ├── microservices-k8s/       # Microservices on Kubernetes
│   ├── monitoring-stack/        # Prometheus + Grafana
│   └── stateful-apps/           # StatefulSets (databases)
│
└── README.md              # This file
```

## Available Services

### Web Servers & Load Balancers

| Service | Purpose | Port | Status |
|---------|---------|------|--------|
| **nginx** | Web server, reverse proxy | 80, 443 | ✅ Ready |
| **apache** | Apache HTTP Server | 80, 443 | ✅ Ready |
| **haproxy** | Load balancer, HA proxy | 80, 443, 8404 | ✅ Ready |

### Application Servers

| Service | Purpose | Port | Status |
|---------|---------|------|--------|
| **tomcat** | Java application server | 8080 | ✅ Ready |

### Databases

| Service | Type | Port | Status |
|---------|------|------|--------|
| **postgresql** | Relational DB | 5432 | ✅ Ready |
| **mongodb** | NoSQL Document DB | 27017 | ✅ Ready |
| **mysql** | Relational DB (MariaDB) | 3306 | ✅ Ready |
| **redis** | In-memory key-value store | 6379 | ✅ Ready |
| **elasticsearch** | Search & analytics engine | 9200 | ✅ Ready |

### Monitoring & Observability

| Service | Purpose | Port | Status |
|---------|---------|------|--------|
| **prometheus** | Metrics collection & storage | 9090 | ✅ Ready |
| **node_exporter** | System metrics exporter | 9100 | ✅ Ready |
| **grafana** | Visualization & dashboards | 3000 | ✅ Ready |
| **zabbix** | Enterprise monitoring | 80, 10051 | ✅ Ready |

### Messaging & Containers

| Service | Purpose | Port | Status |
|---------|---------|------|--------|
| **rabbitmq** | Message broker (AMQP) | 5672, 15672 | ✅ Ready |
| **docker** | Container platform | N/A | ✅ Ready |

## Quick Start

### Installing a Service

Each service has its own directory with installation script and documentation:

```bash
# Navigate to service directory
cd installs/nginx/

# Read the documentation
cat README.md

# Run the installation script (requires root)
sudo bash install_nginx.sh
```

### Deployment Examples

Explore complete deployment architectures:

```bash
# Navigate to deployments
cd deployments/

# Choose a deployment
cd stack-3tier/

# Read the architecture documentation
cat README.md

# Deploy manually or import into Morpheus
```

## Deployment Examples

### 1. 3-Tier Web Application
**Complexity**: ⭐⭐⭐ Intermediate | **Demo Time**: 10-15 min

Classic web application with separate presentation, application, and data tiers.

**Architecture**: nginx → Tomcat → PostgreSQL

**Demonstrates**:
- Multi-tier orchestration
- Variable injection between tiers
- Database initialization
- Automated configuration

**Best for**: DevOps teams, standard web applications

[View Details →](./deployments/stack-3tier/)

---

### 2. Modern Microservices Stack
**Complexity**: ⭐⭐⭐⭐ Advanced | **Demo Time**: 15-20 min

Complete microservices platform with API gateway, multiple services, and messaging.

**Architecture**: nginx Gateway → [User/Product/Order Services] → MongoDB + Redis + RabbitMQ

**Demonstrates**:
- Service orchestration
- Message-driven architecture
- Distributed caching
- API routing and load balancing

**Best for**: DevOps teams, modern cloud-native applications

[View Details →](./deployments/microservices/)

---

### 3. Observability Platform
**Complexity**: ⭐⭐ Basic | **Demo Time**: 10 min

Comprehensive monitoring and observability stack.

**Architecture**: Prometheus + Grafana + Zabbix + Elasticsearch

**Demonstrates**:
- Centralized monitoring
- Metrics collection and visualization
- Enterprise monitoring integration
- Log aggregation

**Best for**: Operations teams, SRE, infrastructure monitoring

[View Details →](./deployments/observability/)

---

### 4. High Availability Web
**Complexity**: ⭐⭐⭐⭐ Advanced | **Demo Time**: 15 min

Production-ready HA web application with redundancy and failover.

**Architecture**: HAProxy (HA) → nginx Cluster → PostgreSQL (Primary/Replica)

**Demonstrates**:
- High availability patterns
- Load balancing with failover
- Database replication
- Health checks and auto-recovery

**Best for**: Infrastructure teams, production deployments

[View Details →](./deployments/ha-web/)

## Features

### Installation Scripts
- ✅ **Multi-distribution support**: Ubuntu, Debian, CentOS, RHEL, Fedora, Arch Linux
- ✅ **Automated installation**: One-command deployment
- ✅ **Service configuration**: Production-ready defaults
- ✅ **Security hardening**: Best practices built-in
- ✅ **Verification checks**: Post-install validation

### Deployment Examples
- ✅ **Architecture diagrams**: Visual representation (ASCII art)
- ✅ **Component specifications**: Detailed resource requirements
- ✅ **Deployment scripts**: Automated or manual deployment
- ✅ **Morpheus blueprints**: App Blueprint YAML examples
- ✅ **Testing procedures**: Validation and health checks
- ✅ **Monitoring integration**: Prometheus and Grafana setup
- ✅ **Scaling strategies**: Horizontal and vertical scaling
- ✅ **Security guidelines**: Best practices and hardening

## Morpheus Integration

### Self-Service Catalogs
Use these scripts to create:
- Instance Types for each service
- Catalog Items for end-user provisioning
- App Blueprints for multi-tier applications
- Workflows for post-provisioning automation

### Cloud Support
All deployments work on:
- ✅ **VMware vCenter** - Production-grade deployments
- ✅ **HVM (HPE VM Essentials)** - Development/testing environments
- ✅ **Unified Catalog** - Single catalog for both clouds

### Automation
- **Post-provisioning tasks**: Service configuration, database initialization
- **Variable injection**: Pass IPs, credentials between tiers
- **Health checks**: Automated validation
- **Workflows**: Multi-step orchestration

### Governance
- **Expiration policies**: Auto-destroy dev environments
- **Cost policies**: Budget alerts and quotas
- **Backup policies**: Automated database backups
- **Approval workflows**: Production deployment controls

## Service Documentation

Each service directory includes:

### README.md
- Service description and use cases
- Installation instructions
- Configuration examples
- Security best practices
- Monitoring and troubleshooting
- Integration guides

### install_[service].sh
- Automated installation script
- OS detection and package installation
- Service configuration
- Startup and enablement
- Verification checks

## Prerequisites

### For Manual Installation
- Linux-based operating system (Ubuntu 22.04 LTS recommended)
- Root or sudo privileges
- Internet connectivity for package downloads

### For Morpheus Deployment
- Morpheus appliance configured
- VMware vCenter and/or HVM integrated
- Networks and storage configured
- Cloud-init enabled on images

## Installation Examples

### Single Service Installation

```bash
# Clone the repository
git clone <repository-url>
cd morpheus-catalog

# Install nginx
cd installs/nginx
sudo bash install_nginx.sh

# Verify installation
systemctl status nginx
curl http://localhost
```

### Multi-Tier Deployment

```bash
# Deploy 3-tier application
cd deployments/stack-3tier

# Follow the deployment guide
cat README.md

# Deploy each tier in order:
# 1. Database tier
# 2. Application tier
# 3. Web tier
```

### Import into Morpheus

1. **Create Instance Types**:
   - Use installation scripts in custom Node Types
   - Configure cloud-init or script execution

2. **Create App Blueprints**:
   - Import YAML from deployment examples
   - Configure tier dependencies
   - Set up variable injection

3. **Publish to Catalog**:
   - Create catalog items from blueprints
   - Set permissions and policies
   - Enable self-service provisioning

## Use Cases for PoC

### For DevOps Teams
- **3-Tier Application**: Standard web app deployment
- **Microservices**: Modern cloud-native architecture
- **CI/CD Integration**: Automated deployment pipelines

### For Infrastructure Teams
- **HA Web Application**: Production-ready redundancy
- **Observability Platform**: Centralized monitoring
- **Database Management**: Automated DB provisioning

### For Management
- **Self-Service Catalog**: Enable developer productivity
- **Cost Management**: Track and optimize spending
- **Governance**: Policies, approvals, compliance

## Security Considerations

All installation scripts follow security best practices:
- ✅ Default passwords should be changed immediately
- ✅ Services configured for minimum necessary access
- ✅ SSL/TLS recommended for production
- ✅ Firewall configuration guidance provided
- ✅ Security updates recommended
- ✅ Principle of least privilege

## Support

### Documentation
- Service-specific README files
- Deployment architecture guides
- Morpheus integration examples

### Troubleshooting
- Common issues documented
- Log file locations provided
- Testing procedures included

### Resources
- HPE Morpheus Documentation: https://docs.morpheusdata.com/
- Community Forums: https://community.hpe.com/
- Support Portal: https://support.hpe.com/

## Contributing

To add a new service or deployment:

1. **Service Installation Script**:
   ```
   service-name/
   ├── README.md
   └── install_service.sh
   ```

2. **Deployment Example**:
   ```
   deployments/XX-deployment-name/
   ├── README.md
   └── deploy.sh (optional)
   ```

3. Follow existing patterns for documentation
4. Test on multiple distributions
5. Include security considerations
6. Add monitoring examples

## License

These examples are provided as reference implementations for HPE Morpheus PoCs and demonstrations.

## Changelog

### 2025-12-06
- ✅ Added 9 additional services (MySQL, Redis, Prometheus, Node Exporter, Tomcat, RabbitMQ, Elasticsearch, HAProxy, Apache)
- ✅ Created 4 complete deployment examples
- ✅ Added comprehensive documentation
- ✅ Included Morpheus App Blueprint examples

### Initial Release
- ✅ Created foundational services (nginx, PostgreSQL, MongoDB, Grafana, Zabbix, Docker)
- ✅ Basic installation scripts
- ✅ Initial repository structure

---

## Getting Started

1. **Browse the services** to understand what's available
2. **Review deployment examples** for your use case
3. **Test individual services** in a dev environment
4. **Import into Morpheus** for automation
5. **Demo to stakeholders** with complete architectures

For questions or support, please refer to the individual service documentation or deployment guides.
