# Apache Tomcat Installation and Configuration

This directory contains scripts and documentation for installing and configuring Apache Tomcat.

## Contents

- `install_tomcat.sh` - Installation script for Apache Tomcat

## Installation

Run the installation script:

```bash
bash install_tomcat.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges
- Java JDK (installed automatically)

## Features

- Automated installation of Apache Tomcat
- Java JDK installation
- Systemd service configuration
- Admin user creation
- Service management

## Usage

After installation, Tomcat will be available as a system service:

```bash
# Start Tomcat
sudo systemctl start tomcat

# Stop Tomcat
sudo systemctl stop tomcat

# Check status
sudo systemctl status tomcat

# Enable on boot
sudo systemctl enable tomcat

# View logs
sudo journalctl -u tomcat -f
# Or
tail -f /opt/tomcat/logs/catalina.out
```

## Configuration

Tomcat configuration files are located at:
- `/opt/tomcat/conf/server.xml` - Main server configuration
- `/opt/tomcat/conf/tomcat-users.xml` - User authentication
- `/opt/tomcat/webapps/` - Web applications directory
- `/opt/tomcat/logs/` - Log files

## Default Access

- Default HTTP port: `8080`
- Default AJP port: `8009`
- Default shutdown port: `8005`
- Manager App: `http://localhost:8080/manager`
- Host Manager: `http://localhost:8080/host-manager`

## Web Interface

Access Tomcat:
```
http://your-server-ip:8080
```

Default admin credentials are set during installation.

## Deploying Applications

### WAR Deployment
```bash
# Copy WAR file to webapps directory
sudo cp myapp.war /opt/tomcat/webapps/

# Tomcat will auto-deploy
# Access at: http://localhost:8080/myapp
```

### Using Manager App
1. Navigate to `http://localhost:8080/manager`
2. Login with admin credentials
3. Use "WAR file to deploy" section
4. Select your WAR file and deploy

## Configuration Files

### server.xml
Main server configuration:
```xml
<!-- Change HTTP port -->
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

### tomcat-users.xml
User management:
```xml
<tomcat-users>
  <role rolename="manager-gui"/>
  <role rolename="admin-gui"/>
  <user username="admin" password="your_password" roles="manager-gui,admin-gui"/>
</tomcat-users>
```

## Performance Tuning

### JVM Options
Edit `/opt/tomcat/bin/setenv.sh`:

```bash
export CATALINA_OPTS="-Xms512M -Xmx1024M -XX:MaxPermSize=256M"
export JAVA_OPTS="-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"
```

### Connection Pool
Edit `server.xml`:
```xml
<Connector port="8080" protocol="HTTP/1.1"
           maxThreads="200"
           minSpareThreads="25"
           maxConnections="200"
           connectionTimeout="20000" />
```

## SSL/TLS Configuration

Generate keystore:
```bash
keytool -genkey -alias tomcat -keyalg RSA -keystore /opt/tomcat/keystore.jks
```

Configure in `server.xml`:
```xml
<Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
           maxThreads="150" SSLEnabled="true">
    <SSLHostConfig>
        <Certificate certificateKeystoreFile="/opt/tomcat/keystore.jks"
                     type="RSA" />
    </SSLHostConfig>
</Connector>
```

## Monitoring

### Manager Status
- `http://localhost:8080/manager/status`
- View running applications, sessions, and resources

### JMX Monitoring
Enable JMX in `setenv.sh`:
```bash
export CATALINA_OPTS="-Dcom.sun.management.jmxremote \
  -Dcom.sun.management.jmxremote.port=9999 \
  -Dcom.sun.management.jmxremote.ssl=false \
  -Dcom.sun.management.jmxremote.authenticate=false"
```

## Security Best Practices

- Change default passwords immediately
- Remove default applications in production
- Configure SSL/TLS for production
- Use security manager in production
- Keep Tomcat and Java updated
- Restrict access to manager applications
- Use firewall rules
- Enable access logging
- Regular security audits

## Log Files

Main log files:
- `catalina.out` - Main Tomcat log
- `localhost.log` - Localhost application log
- `manager.log` - Manager application log
- `host-manager.log` - Host manager log
- `access_log` - HTTP access log

## Troubleshooting

Check if Tomcat is running:
```bash
sudo systemctl status tomcat
ps aux | grep tomcat
```

Check port usage:
```bash
sudo netstat -tulpn | grep 8080
```

View recent logs:
```bash
tail -n 100 /opt/tomcat/logs/catalina.out
```

## Useful Resources

- Tomcat Documentation: https://tomcat.apache.org/tomcat-10.1-doc/
- Tomcat Wiki: https://cwiki.apache.org/confluence/display/TOMCAT/
