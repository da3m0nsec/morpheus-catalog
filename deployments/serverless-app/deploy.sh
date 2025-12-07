#!/bin/bash
#
# Deploy Serverless Application to Apache OpenServerless
# This script creates packages, deploys functions, creates sequences, and sets up API endpoints
#

set -e

echo "=========================================="
echo "Deploying Serverless Application"
echo "=========================================="
echo ""

# Check if ops CLI is available
if ! command -v ops &> /dev/null; then
    echo "Error: ops CLI is not installed"
    echo "Please install OpenServerless first: see ../installs/openserverless/"
    exit 1
fi

# Check if ops is configured
if ! ops namespace list &> /dev/null; then
    echo "Error: ops CLI is not configured"
    echo "Please run: ops config or check OpenServerless installation"
    exit 1
fi

echo "Step 1: Creating packages..."
echo "----------------------------"

# Create packages for organization
ops package create user-service || echo "Package user-service already exists"
ops package create data-service || echo "Package data-service already exists"
ops package create utils || echo "Package utils already exists"

echo "✓ Packages created"
echo ""

echo "Step 2: Deploying User Management Functions..."
echo "-----------------------------------------------"

# Deploy user management functions (Python)
ops action create user-service/listUsers functions/listUsers.py --kind python:3.11 || \
    ops action update user-service/listUsers functions/listUsers.py --kind python:3.11

ops action create user-service/getUser functions/getUser.py --kind python:3.11 || \
    ops action update user-service/getUser functions/getUser.py --kind python:3.11

ops action create user-service/createUser functions/createUser.py --kind python:3.11 || \
    ops action update user-service/createUser functions/createUser.py --kind python:3.11

ops action create user-service/updateUser functions/updateUser.py --kind python:3.11 || \
    ops action update user-service/updateUser functions/updateUser.py --kind python:3.11

ops action create user-service/deleteUser functions/deleteUser.py --kind python:3.11 || \
    ops action update user-service/deleteUser functions/deleteUser.py --kind python:3.11

echo "✓ User management functions deployed"
echo ""

echo "Step 3: Deploying Data Processing Functions..."
echo "-----------------------------------------------"

# Deploy data processing functions (Node.js)
ops action create data-service/validateData functions/validateData.js --kind nodejs:18 || \
    ops action update data-service/validateData functions/validateData.js --kind nodejs:18

ops action create data-service/processData functions/processData.js --kind nodejs:18 || \
    ops action update data-service/processData functions/processData.js --kind nodejs:18

ops action create data-service/enrichData functions/enrichData.js --kind nodejs:18 || \
    ops action update data-service/enrichData functions/enrichData.js --kind nodejs:18

echo "✓ Data processing functions deployed"
echo ""

echo "Step 4: Deploying Utility Functions..."
echo "---------------------------------------"

# Deploy utility functions (Python)
ops action create utils/sendNotification functions/sendNotification.py --kind python:3.11 || \
    ops action update utils/sendNotification functions/sendNotification.py --kind python:3.11

ops action create utils/logEvent functions/logEvent.py --kind python:3.11 || \
    ops action update utils/logEvent functions/logEvent.py --kind python:3.11

echo "✓ Utility functions deployed"
echo ""

echo "Step 5: Creating Function Sequences..."
echo "---------------------------------------"

# Create data processing pipeline
ops action create dataProcessingPipeline \
    --sequence data-service/validateData,data-service/processData,data-service/enrichData || \
    ops action update dataProcessingPipeline \
    --sequence data-service/validateData,data-service/processData,data-service/enrichData

# Create user creation workflow
ops action create userCreationWorkflow \
    --sequence user-service/createUser,utils/sendNotification,utils/logEvent || \
    ops action update userCreationWorkflow \
    --sequence user-service/createUser,utils/sendNotification,utils/logEvent

echo "✓ Function sequences created"
echo ""

echo "Step 6: Creating API Endpoints..."
echo "----------------------------------"

# Create API endpoints for user management
ops api create /users GET user-service/listUsers --response-type json || \
    echo "API GET /users already exists"

ops api create /users POST user-service/createUser --response-type json || \
    echo "API POST /users already exists"

ops api create /users/{id} GET user-service/getUser --response-type json || \
    echo "API GET /users/{id} already exists"

ops api create /users/{id} PUT user-service/updateUser --response-type json || \
    echo "API PUT /users/{id} already exists"

ops api create /users/{id} DELETE user-service/deleteUser --response-type json || \
    echo "API DELETE /users/{id} already exists"

# Create API endpoint for data processing
ops api create /process POST dataProcessingPipeline --response-type json || \
    echo "API POST /process already exists"

echo "✓ API endpoints created"
echo ""

echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""

# Get API host
API_HOST=$(ops apihost get 2>/dev/null || echo "Not available")
echo "API Host: $API_HOST"
echo ""

echo "Available Endpoints:"
echo "  GET    $API_HOST/api/v1/web/default/users"
echo "  POST   $API_HOST/api/v1/web/default/users"
echo "  GET    $API_HOST/api/v1/web/default/users/{id}"
echo "  PUT    $API_HOST/api/v1/web/default/users/{id}"
echo "  DELETE $API_HOST/api/v1/web/default/users/{id}"
echo "  POST   $API_HOST/api/v1/web/default/process"
echo ""

echo "Test the deployment:"
echo "  bash tests/test_users.sh"
echo "  bash tests/test_data.sh"
echo ""

echo "View deployed resources:"
echo "  ops action list"
echo "  ops package list"
echo "  ops api list"
echo ""

echo "Monitor activations:"
echo "  ops activation poll"
echo ""
