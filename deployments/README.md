# Deployment Examples for Morpheus PoC

This directory contains complete deployment examples demonstrating HPE Morpheus capabilities with VMware on-premises and HVM infrastructure.

## Overview

Each deployment example showcases different aspects of Morpheus:
- **Self-service catalogs** - Users can deploy complete stacks with one click
- **Multi-tier applications** - Orchestrated deployment of complex architectures
- **Automation & governance** - Workflows, policies, and cost management
- **Hybrid cloud** - Deploy across VMware and HVM from a single catalog

## Deployment Examples

### 1. [3-Tier Web Application](./stack-3tier/)
**Complexity**: ⭐⭐⭐ Intermediate

Classic web application architecture with separate web, application, and database tiers.

**Components**:
- Web Tier: nginx (reverse proxy)
- App Tier: Apache Tomcat (Java application server)
- Database Tier: PostgreSQL or MySQL
- Monitoring: Prometheus + Node Exporter

**Demonstrates**:
- Multi-tier orchestration
- Variable injection between tiers
- Load balancing configuration
- Database initialization
- Automated monitoring setup

**Best for**: DevOps teams, Application deployments

---

### 2. [Modern Microservices Stack](./microservices/)
**Complexity**: ⭐⭐⭐⭐ Advanced

Complete microservices platform with API gateway, multiple services, messaging, and caching.

**Components**:
- API Gateway: nginx
- Application Servers: Multiple Tomcat instances
- Databases: MongoDB + Redis (cache)
- Message Queue: RabbitMQ
- Monitoring: Prometheus + Grafana

**Demonstrates**:
- Service discovery and routing
- Message-driven architecture
- Distributed caching
- Container-ready deployments
- Advanced monitoring

**Best for**: DevOps teams, Microservices architecture

---

### 3. [Observability Platform](./observability/)
**Complexity**: ⭐⭐ Basic

Complete monitoring and observability stack for infrastructure and applications.

**Components**:
- Metrics: Prometheus + Node Exporter
- Visualization: Grafana
- Enterprise Monitoring: Zabbix
- Search: Elasticsearch

**Demonstrates**:
- Centralized monitoring
- Metrics collection and visualization
- Multi-tool integration
- Dashboard automation
- Alert configuration

**Best for**: Infrastructure teams, SRE, Operations

---

### 4. [High Availability Web](./ha-web/)
**Complexity**: ⭐⭐⭐⭐ Advanced

Highly available web application with load balancing, redundancy, and failover.

**Components**:
- Load Balancer: HAProxy (multi-instance)
- Web Servers: Multiple nginx instances
- Database: PostgreSQL with replication
- Monitoring: Prometheus + Grafana

**Demonstrates**:
- High availability patterns
- Load balancing strategies
- Database replication
- Health checks and failover
- Scalability planning

**Best for**: Infrastructure teams, Production deployments

---

## How to Use These Examples

### For Morpheus Administrators

1. **Review the architecture** in each deployment's README
2. **Import the blueprints** into Morpheus Library
3. **Configure cloud mappings** for VMware and HVM
4. **Set up instance types** if not already defined
5. **Create catalog items** for self-service

### For Developers/Users

1. Access the **Morpheus catalog**
2. Select the desired deployment
3. Fill in required parameters (names, sizes, passwords)
4. Choose target cloud (VMware or HVM)
5. Click **Deploy** and monitor progress

### For PoC Demonstrations

Each deployment is designed to showcase specific Morpheus capabilities:

| Deployment | Focus Area | Demo Duration | Audience |
|------------|------------|---------------|----------|
| 3-Tier Web | Multi-tier orchestration, variables | 10-15 min | DevOps, Management |
| Microservices | Modern architecture, complexity | 15-20 min | DevOps, Architects |
| Observability | Monitoring, governance | 10 min | Operations, SRE |
| HA Web | Availability, production patterns | 15 min | Infrastructure, Architects |

## Integration with Morpheus

### App Blueprints

Each deployment includes a suggested App Blueprint structure that can be imported into Morpheus.

### Instance Types

Deployments leverage both:
- **Built-in instance types** (Ubuntu, CentOS)
- **Custom instance types** (preconfigured services)

### Workflows

Post-provisioning automation includes:
- Service configuration
- Application deployment
- Monitoring setup
- Health checks
- Documentation generation

### Policies

Governance examples:
- **Expiration policies** - Auto-destroy dev environments
- **Cost policies** - Budget alerts and quotas
- **Backup policies** - Automated backups for databases
- **Approval policies** - Require approval for production

## Cloud Configuration

### VMware vCenter
- Production-grade deployments
- Larger resource plans
- Enterprise features

### HVM (HPE VM Essentials)
- Development/testing environments
- Smaller resource plans
- Cost optimization

### Unified Catalog

All deployments work on both clouds through:
- Cloud-agnostic blueprints
- Environment-specific plans
- Resource mapping

## Prerequisites

### Infrastructure
- Morpheus appliance configured
- VMware vCenter integrated
- HVM integrated
- Networks configured
- Storage available

### Images
- Ubuntu 22.04 LTS (recommended)
- CentOS 8 / Rocky Linux 8
- Cloud-init enabled

### Networking
- DNS resolution
- Firewall rules configured
- Load balancer IPs available (for HA deployments)

## Quick Start

1. **Clone this repository**
   ```bash
   git clone <repository-url>
   cd morpheus-catalog/deployments
   ```

2. **Choose a deployment**
   ```bash
   cd stack-3tier
   cat README.md
   ```

3. **Review the architecture and requirements**

4. **Deploy manually** (for testing)
   ```bash
   # Deploy each tier following the deployment order
   bash ../nginx/install_nginx.sh
   bash ../tomcat/install_tomcat.sh
   bash ../postgresql/install_postgresql.sh
   ```

5. **Import into Morpheus** for automated deployment

## Best Practices

### Resource Planning
- Start with smaller plans for testing
- Scale up for production
- Use quotas to prevent overprovisioning

### Security
- Change all default passwords
- Enable SSL/TLS for production
- Configure firewalls properly
- Use secrets management

### Monitoring
- Always include monitoring components
- Set up alerts for critical services
- Use dashboards for visibility

### Governance
- Apply expiration policies to dev/test
- Use approval workflows for production
- Enable costing for showback

## Support & Documentation

- **Morpheus Docs**: https://docs.morpheusdata.com/
- **HPE Morpheus**: https://www.hpe.com/morpheus
- **Service Scripts**: See individual service folders in parent directory

## Contributing

To add a new deployment example:
1. Create a new directory: `deployments/XX-deployment-name/`
2. Add complete documentation (README.md)
3. Include architecture diagram
4. Provide deployment scripts
5. Create Morpheus blueprint JSON/YAML
6. Update this main README

## License

These examples are provided as reference implementations for HPE Morpheus PoCs and demonstrations.
