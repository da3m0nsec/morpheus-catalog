# HAProxy Installation and Configuration

This directory contains scripts and documentation for installing and configuring HAProxy.

## Contents

- `install_haproxy.sh` - Installation script for HAProxy

## Installation

Run the installation script:

```bash
bash install_haproxy.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges

## Features

- Automated installation of HAProxy
- Basic load balancing configuration
- Statistics page enabled
- Service management
- HTTP and TCP load balancing

## Usage

After installation, HAProxy will be available as a system service:

```bash
# Start HAProxy
sudo systemctl start haproxy

# Stop HAProxy
sudo systemctl stop haproxy

# Check status
sudo systemctl status haproxy

# Enable on boot
sudo systemctl enable haproxy

# Reload configuration
sudo systemctl reload haproxy

# View logs
sudo journalctl -u haproxy -f
```

## Configuration

HAProxy configuration file is located at:
- `/etc/haproxy/haproxy.cfg` - Main configuration file

## Default Access

- Frontend HTTP port: `80`
- Statistics page: `http://localhost:8404/stats`
- Admin socket: `/var/run/haproxy.sock`

## Statistics Page

Access HAProxy statistics:
```
http://your-server-ip:8404/stats
```

Default credentials (if authentication enabled):
- Username: `admin`
- Password: `admin`

## Basic Configuration Example

Edit `/etc/haproxy/haproxy.cfg`:

```haproxy
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

# Frontend for HTTP traffic
frontend http_front
    bind *:80
    default_backend http_back

# Backend servers
backend http_back
    balance roundrobin
    server web1 192.168.1.10:80 check
    server web2 192.168.1.11:80 check
    server web3 192.168.1.12:80 check
```

## Load Balancing Algorithms

```haproxy
# Round Robin (default)
balance roundrobin

# Least connections
balance leastconn

# Source IP hash
balance source

# URI hash
balance uri

# First available
balance first
```

## Health Checks

```haproxy
# Basic HTTP check
server web1 192.168.1.10:80 check

# Custom interval and timeout
server web2 192.168.1.11:80 check inter 2000 rise 2 fall 3

# HTTP health check with specific URI
option httpchk GET /health

# TCP health check
option tcp-check
```

## SSL/TLS Termination

```haproxy
frontend https_front
    bind *:443 ssl crt /etc/haproxy/certs/server.pem
    default_backend web_servers

backend web_servers
    balance roundrobin
    server web1 192.168.1.10:80 check
    server web2 192.168.1.11:80 check
```

## TCP Load Balancing

```haproxy
# MySQL load balancing
listen mysql_cluster
    bind *:3306
    mode tcp
    balance leastconn
    option tcp-check
    server mysql1 192.168.1.20:3306 check
    server mysql2 192.168.1.21:3306 check
```

## ACLs and Routing

```haproxy
frontend http_front
    bind *:80

    # Define ACLs
    acl is_api path_beg /api
    acl is_admin path_beg /admin

    # Route based on ACLs
    use_backend api_servers if is_api
    use_backend admin_servers if is_admin
    default_backend web_servers

backend api_servers
    balance roundrobin
    server api1 192.168.1.30:8080 check

backend admin_servers
    balance roundrobin
    server admin1 192.168.1.40:8080 check

backend web_servers
    balance roundrobin
    server web1 192.168.1.50:80 check
```

## Sticky Sessions

```haproxy
backend web_servers
    balance roundrobin
    cookie SERVERID insert indirect nocache
    server web1 192.168.1.10:80 check cookie web1
    server web2 192.168.1.11:80 check cookie web2
```

## Rate Limiting

```haproxy
frontend http_front
    bind *:80

    # Track client IP
    stick-table type ip size 100k expire 30s store http_req_rate(10s)

    # Rate limit: 100 requests per 10 seconds
    acl too_fast sc_http_req_rate(0) gt 100
    http-request track-sc0 src
    http-request deny if too_fast

    default_backend web_servers
```

## Testing Configuration

```bash
# Check configuration syntax
sudo haproxy -c -f /etc/haproxy/haproxy.cfg

# Reload configuration without downtime
sudo systemctl reload haproxy
```

## Monitoring

### Using Statistics Page
- Real-time server status
- Request rates and errors
- Session information
- Health check status

### Using HAProxy Socket
```bash
# Show statistics
echo "show stat" | sudo socat stdio /var/run/haproxy.sock

# Show server states
echo "show servers state" | sudo socat stdio /var/run/haproxy.sock

# Disable a server
echo "disable server backend_name/server_name" | sudo socat stdio /var/run/haproxy.sock

# Enable a server
echo "enable server backend_name/server_name" | sudo socat stdio /var/run/haproxy.sock
```

## High Availability

### Using Keepalived for HA
```bash
# Install keepalived
apt-get install keepalived

# Configure virtual IP
# Edit /etc/keepalived/keepalived.conf
```

## Logging

### Send logs to rsyslog
Edit `/etc/rsyslog.d/haproxy.conf`:
```
$ModLoad imudp
$UDPServerAddress 127.0.0.1
$UDPServerRun 514

local0.* /var/log/haproxy.log
```

Restart rsyslog:
```bash
sudo systemctl restart rsyslog
```

## Performance Tuning

```haproxy
global
    maxconn 100000
    nbproc 4           # Use 4 processes
    cpu-map 1 0
    cpu-map 2 1
    cpu-map 3 2
    cpu-map 4 3

defaults
    timeout connect 5s
    timeout client 30s
    timeout server 30s
    maxconn 50000
```

## Security Best Practices

- Use SSL/TLS for sensitive traffic
- Implement rate limiting
- Enable logging and monitoring
- Use ACLs to restrict access
- Change default statistics credentials
- Keep HAProxy updated
- Implement DDoS protection
- Use security headers

## Common Use Cases

1. **Web application load balancing**
2. **Database load balancing**
3. **SSL/TLS termination**
4. **API gateway**
5. **Microservices routing**
6. **Blue-green deployments**
7. **A/B testing**
8. **Geographic routing**

## Troubleshooting

Check if HAProxy is running:
```bash
sudo systemctl status haproxy
```

Check port bindings:
```bash
sudo netstat -tulpn | grep haproxy
```

View logs:
```bash
sudo tail -f /var/log/haproxy.log
sudo journalctl -u haproxy -f
```

Test backend connectivity:
```bash
curl http://backend-server-ip
```

## Useful Resources

- HAProxy Documentation: http://www.haproxy.org/
- HAProxy Configuration Manual: http://cbonte.github.io/haproxy-dconv/
- HAProxy Blog: https://www.haproxy.com/blog/
