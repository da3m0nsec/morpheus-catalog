#!/bin/bash

# Apache Tomcat Installation Script
# This script installs Apache Tomcat on Linux systems

set -e

echo "========================================="
echo "Apache Tomcat Installation Script"
echo "========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    echo "Cannot detect OS version"
    exit 1
fi

echo "Detected OS: $OS $VERSION"

# Tomcat version to install
TOMCAT_MAJOR_VERSION="10"
TOMCAT_VERSION="10.1.17"

# Install Java based on OS
echo "Installing Java JDK..."
case $OS in
    ubuntu|debian)
        apt-get update
        apt-get install -y openjdk-17-jdk wget
        ;;
    centos|rhel|fedora)
        if command -v dnf &> /dev/null; then
            dnf install -y java-17-openjdk-devel wget
        else
            yum install -y java-17-openjdk-devel wget
        fi
        ;;
    arch)
        pacman -Sy --noconfirm jdk17-openjdk wget
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Verify Java installation
java -version

# Create tomcat user
echo "Creating tomcat user..."
if ! id -u tomcat > /dev/null 2>&1; then
    useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat
fi

# Download Tomcat
echo "Downloading Apache Tomcat ${TOMCAT_VERSION}..."
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Extract Tomcat
echo "Extracting Tomcat..."
tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Move to installation directory
if [ -d "/opt/tomcat" ]; then
    rm -rf /opt/tomcat/*
fi
mkdir -p /opt/tomcat
mv apache-tomcat-${TOMCAT_VERSION}/* /opt/tomcat/

# Set permissions
echo "Setting permissions..."
chown -R tomcat:tomcat /opt/tomcat/
chmod -R u+x /opt/tomcat/bin/

# Create setenv.sh for JVM options
cat > /opt/tomcat/bin/setenv.sh <<'EOF'
#!/bin/bash
export CATALINA_OPTS="-Xms512M -Xmx1024M -XX:MaxMetaspaceSize=256M"
export JAVA_OPTS="-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"
EOF

chmod +x /opt/tomcat/bin/setenv.sh
chown tomcat:tomcat /opt/tomcat/bin/setenv.sh

# Configure tomcat-users.xml
echo "Configuring admin user..."
cat > /opt/tomcat/conf/tomcat-users.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <role rolename="manager-jmx"/>
  <role rolename="manager-status"/>
  <role rolename="admin-gui"/>
  <role rolename="admin-script"/>
  <user username="admin" password="admin" roles="manager-gui,manager-script,manager-jmx,manager-status,admin-gui,admin-script"/>
</tomcat-users>
EOF

chown tomcat:tomcat /opt/tomcat/conf/tomcat-users.xml

# Remove IP restrictions for manager and host-manager
sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/,/\/>/d' /opt/tomcat/webapps/manager/META-INF/context.xml 2>/dev/null || true
sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/,/\/>/d' /opt/tomcat/webapps/host-manager/META-INF/context.xml 2>/dev/null || true

# Create systemd service
echo "Creating systemd service..."
cat > /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Find correct JAVA_HOME and update service file
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
sed -i "s|Environment=\"JAVA_HOME=.*\"|Environment=\"JAVA_HOME=$JAVA_HOME\"|" /etc/systemd/system/tomcat.service

# Reload systemd
systemctl daemon-reload

# Start and enable Tomcat
echo "Starting Tomcat service..."
systemctl start tomcat
systemctl enable tomcat

# Clean up
cd /tmp
rm -f apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Wait for Tomcat to start
echo "Waiting for Tomcat to start..."
sleep 10

# Check service status
echo ""
echo "========================================="
echo "Apache Tomcat Installation Complete!"
echo "========================================="
systemctl status tomcat --no-pager

echo ""
echo "Apache Tomcat ${TOMCAT_VERSION} has been installed successfully!"
echo ""
echo "Access Tomcat at: http://localhost:8080"
echo "Manager App: http://localhost:8080/manager"
echo "Host Manager: http://localhost:8080/host-manager"
echo ""
echo "Default admin credentials:"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "IMPORTANT: Change the default password in /opt/tomcat/conf/tomcat-users.xml"
echo ""
echo "Installation directory: /opt/tomcat"
echo "Configuration: /opt/tomcat/conf"
echo "Webapps: /opt/tomcat/webapps"
echo "Logs: /opt/tomcat/logs"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status tomcat"
echo "  sudo systemctl restart tomcat"
echo "  sudo journalctl -u tomcat -f"
echo "  tail -f /opt/tomcat/logs/catalina.out"
