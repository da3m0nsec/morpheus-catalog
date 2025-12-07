#!/bin/bash
#
# Cleanup Serverless Application from Apache OpenServerless
# This script removes all deployed functions, packages, and API endpoints
#

set -e

echo "=========================================="
echo "Cleaning up Serverless Application"
echo "=========================================="
echo ""

# Check if ops CLI is available
if ! command -v ops &> /dev/null; then
    echo "Error: ops CLI is not installed"
    exit 1
fi

read -p "Are you sure you want to delete all resources? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled"
    exit 0
fi

echo ""
echo "Step 1: Deleting API Endpoints..."
echo "----------------------------------"

# Delete API endpoints
ops api delete /users GET || echo "API GET /users not found"
ops api delete /users POST || echo "API POST /users not found"
ops api delete /users/{id} GET || echo "API GET /users/{id} not found"
ops api delete /users/{id} PUT || echo "API PUT /users/{id} not found"
ops api delete /users/{id} DELETE || echo "API DELETE /users/{id} not found"
ops api delete /process POST || echo "API POST /process not found"

echo "✓ API endpoints deleted"
echo ""

echo "Step 2: Deleting Sequences..."
echo "------------------------------"

# Delete sequences
ops action delete dataProcessingPipeline || echo "Sequence dataProcessingPipeline not found"
ops action delete userCreationWorkflow || echo "Sequence userCreationWorkflow not found"

echo "✓ Sequences deleted"
echo ""

echo "Step 3: Deleting Actions..."
echo "---------------------------"

# Delete user management actions
ops action delete user-service/listUsers || echo "Action user-service/listUsers not found"
ops action delete user-service/getUser || echo "Action user-service/getUser not found"
ops action delete user-service/createUser || echo "Action user-service/createUser not found"
ops action delete user-service/updateUser || echo "Action user-service/updateUser not found"
ops action delete user-service/deleteUser || echo "Action user-service/deleteUser not found"

# Delete data processing actions
ops action delete data-service/validateData || echo "Action data-service/validateData not found"
ops action delete data-service/processData || echo "Action data-service/processData not found"
ops action delete data-service/enrichData || echo "Action data-service/enrichData not found"

# Delete utility actions
ops action delete utils/sendNotification || echo "Action utils/sendNotification not found"
ops action delete utils/logEvent || echo "Action utils/logEvent not found"

echo "✓ Actions deleted"
echo ""

echo "Step 4: Deleting Packages..."
echo "-----------------------------"

# Delete packages
ops package delete user-service || echo "Package user-service not found"
ops package delete data-service || echo "Package data-service not found"
ops package delete utils || echo "Package utils not found"

echo "✓ Packages deleted"
echo ""

echo "=========================================="
echo "Cleanup Complete!"
echo "=========================================="
echo ""

echo "Verify cleanup:"
echo "  ops action list"
echo "  ops package list"
echo "  ops api list"
echo ""
