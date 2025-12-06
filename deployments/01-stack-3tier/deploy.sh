#!/bin/bash

# 3-Tier Web Application Deployment Script
# This script helps deploy the 3-tier architecture manually

set -e

echo "============================================="
echo "3-Tier Web Application Deployment"
echo "============================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root or with sudo"
    exit 1
fi

# Get deployment parameters
echo "Enter deployment parameters:"
echo ""

read -p "Database VM IP address: " DB_IP
read -p "Application VM IP address: " APP_IP
read -p "Web VM IP address: " WEB_IP
echo ""
read -p "Database name [webapp]: " DB_NAME
DB_NAME=${DB_NAME:-webapp}
read -p "Database user [webappuser]: " DB_USER
DB_USER=${DB_USER:-webappuser}
read -s -p "Database password: " DB_PASSWORD
echo ""
echo ""

# Confirm deployment
echo "============================================="
echo "Deployment Summary:"
echo "============================================="
echo "Database Tier:"
echo "  IP: $DB_IP"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo ""
echo "Application Tier:"
echo "  IP: $APP_IP"
echo ""
echo "Web Tier:"
echo "  IP: $WEB_IP"
echo "============================================="
echo ""
read -p "Proceed with deployment? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    print_warn "Deployment cancelled"
    exit 0
fi

# Get current host IP
CURRENT_IP=$(hostname -I | awk '{print $1}')
print_info "Current host IP: $CURRENT_IP"
echo ""

# Determine which tier to deploy
if [ "$CURRENT_IP" == "$DB_IP" ]; then
    TIER="database"
elif [ "$CURRENT_IP" == "$APP_IP" ]; then
    TIER="application"
elif [ "$CURRENT_IP" == "$WEB_IP" ]; then
    TIER="web"
else
    print_error "Current IP does not match any tier IP"
    print_warn "Please run this script on one of the tier VMs"
    exit 1
fi

print_info "Detected tier: $TIER"
echo ""

# Deploy based on tier
case $TIER in
    database)
        print_info "Deploying DATABASE TIER..."
        echo ""

        # Install PostgreSQL
        if [ ! -f "../../postgresql/install_postgresql.sh" ]; then
            print_error "PostgreSQL installation script not found"
            exit 1
        fi

        bash ../../postgresql/install_postgresql.sh

        # Wait for PostgreSQL to be ready
        sleep 5

        # Create database and user
        print_info "Creating database and user..."
        sudo -u postgres psql <<EOF
CREATE DATABASE ${DB_NAME};
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};
\c ${DB_NAME}
CREATE TABLE IF NOT EXISTS app_info (
    id SERIAL PRIMARY KEY,
    key VARCHAR(255) NOT NULL,
    value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO app_info (key, value) VALUES ('deployment_date', NOW()::TEXT);
INSERT INTO app_info (key, value) VALUES ('tier', 'database');
EOF

        # Configure PostgreSQL for remote access
        print_info "Configuring PostgreSQL for remote access..."
        PG_CONF=$(find /etc/postgresql -name postgresql.conf | head -1)
        PG_HBA=$(find /etc/postgresql -name pg_hba.conf | head -1)

        if [ -n "$PG_CONF" ]; then
            sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
            echo "host    all    all    0.0.0.0/0    md5" >> "$PG_HBA"
            systemctl restart postgresql
        fi

        print_info "Database tier deployment complete!"
        echo ""
        print_info "Connection details:"
        echo "  Host: $DB_IP"
        echo "  Port: 5432"
        echo "  Database: $DB_NAME"
        echo "  User: $DB_USER"
        ;;

    application)
        print_info "Deploying APPLICATION TIER..."
        echo ""

        # Install Tomcat
        if [ ! -f "../../tomcat/install_tomcat.sh" ]; then
            print_error "Tomcat installation script not found"
            exit 1
        fi

        bash ../../tomcat/install_tomcat.sh

        # Create application properties
        print_info "Configuring database connection..."
        mkdir -p /opt/tomcat/webapps/ROOT/WEB-INF/classes
        cat > /opt/tomcat/webapps/ROOT/WEB-INF/classes/application.properties <<EOF
# Database Configuration
db.host=${DB_IP}
db.port=5432
db.name=${DB_NAME}
db.user=${DB_USER}
db.password=${DB_PASSWORD}

# Application Configuration
app.name=3-Tier Demo Application
app.tier=application
app.version=1.0.0
EOF

        # Create a simple test application
        print_info "Deploying test application..."
        mkdir -p /opt/tomcat/webapps/ROOT
        cat > /opt/tomcat/webapps/ROOT/index.jsp <<'EOF'
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>3-Tier Application</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; background-color: #f0f0f0; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .success { color: #28a745; }
        .error { color: #dc3545; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #007bff; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h1>3-Tier Demo Application</h1>
        <p><strong>Application Tier</strong></p>
        <hr>
        <%
            Properties props = new Properties();
            try {
                FileInputStream fis = new FileInputStream("/opt/tomcat/webapps/ROOT/WEB-INF/classes/application.properties");
                props.load(fis);
                fis.close();

                String dbHost = props.getProperty("db.host");
                String dbPort = props.getProperty("db.port");
                String dbName = props.getProperty("db.name");
                String dbUser = props.getProperty("db.user");
                String dbPassword = props.getProperty("db.password");

                out.println("<h2 class='success'>✓ Configuration Loaded</h2>");
                out.println("<table>");
                out.println("<tr><th>Property</th><th>Value</th></tr>");
                out.println("<tr><td>Database Host</td><td>" + dbHost + "</td></tr>");
                out.println("<tr><td>Database Port</td><td>" + dbPort + "</td></tr>");
                out.println("<tr><td>Database Name</td><td>" + dbName + "</td></tr>");
                out.println("<tr><td>Database User</td><td>" + dbUser + "</td></tr>");
                out.println("</table>");

                // Test database connection
                String url = "jdbc:postgresql://" + dbHost + ":" + dbPort + "/" + dbName;
                Class.forName("org.postgresql.Driver");
                Connection conn = DriverManager.getConnection(url, dbUser, dbPassword);

                out.println("<h2 class='success'>✓ Database Connection Successful</h2>");

                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT key, value, created_at FROM app_info");

                out.println("<h3>Data from Database:</h3>");
                out.println("<table>");
                out.println("<tr><th>Key</th><th>Value</th><th>Created At</th></tr>");
                while(rs.next()) {
                    out.println("<tr><td>" + rs.getString("key") + "</td><td>" + rs.getString("value") + "</td><td>" + rs.getString("created_at") + "</td></tr>");
                }
                out.println("</table>");

                rs.close();
                stmt.close();
                conn.close();

            } catch (Exception e) {
                out.println("<h2 class='error'>✗ Error</h2>");
                out.println("<pre>" + e.getMessage() + "</pre>");
                e.printStackTrace();
            }
        %>
        <hr>
        <p><small>Tier: Application | Server Time: <%= new java.util.Date() %></small></p>
    </div>
</body>
</html>
EOF

        chown -R tomcat:tomcat /opt/tomcat/webapps/ROOT
        systemctl restart tomcat

        print_info "Application tier deployment complete!"
        echo ""
        print_info "Access application at: http://$APP_IP:8080"
        ;;

    web)
        print_info "Deploying WEB TIER..."
        echo ""

        # Install nginx
        if [ ! -f "../../nginx/install_nginx.sh" ]; then
            print_error "nginx installation script not found"
            exit 1
        fi

        bash ../../nginx/install_nginx.sh

        # Configure reverse proxy
        print_info "Configuring reverse proxy..."
        cat > /etc/nginx/sites-available/webapp <<EOF
upstream app_backend {
    server ${APP_IP}:8080;
}

server {
    listen 80;
    server_name _;

    access_log /var/log/nginx/webapp-access.log;
    error_log /var/log/nginx/webapp-error.log;

    location / {
        proxy_pass http://app_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # nginx status page (restricted)
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }
}
EOF

        ln -sf /etc/nginx/sites-available/webapp /etc/nginx/sites-enabled/
        rm -f /etc/nginx/sites-enabled/default

        nginx -t
        systemctl reload nginx

        print_info "Web tier deployment complete!"
        echo ""
        print_info "Access application at: http://$WEB_IP"
        ;;
esac

echo ""
echo "============================================="
print_info "Deployment completed successfully!"
echo "============================================="
echo ""
print_info "Deployment Summary:"
echo "  - Database Tier: http://$DB_IP:5432"
echo "  - Application Tier: http://$APP_IP:8080"
echo "  - Web Tier: http://$WEB_IP"
echo ""
print_info "To access the application, open a browser and navigate to:"
echo "  http://$WEB_IP"
echo ""
