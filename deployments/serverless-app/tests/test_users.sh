#!/bin/bash
#
# Test User Management API Endpoints
#

set -e

echo "=========================================="
echo "Testing User Management APIs"
echo "=========================================="
echo ""

# Get API host
API_HOST=$(ops apihost get 2>/dev/null)
if [ -z "$API_HOST" ]; then
    echo "Error: Cannot get API host. Is OpenServerless running?"
    exit 1
fi

echo "API Host: $API_HOST"
echo ""

# Test 1: Create a user
echo "Test 1: Create a new user"
echo "-------------------------"
CREATE_RESPONSE=$(curl -s -X POST "$API_HOST/api/v1/web/default/users" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "role": "developer"
  }')

echo "Response:"
echo "$CREATE_RESPONSE" | jq '.' 2>/dev/null || echo "$CREATE_RESPONSE"
echo ""

# Extract user ID from response
USER_ID=$(echo "$CREATE_RESPONSE" | jq -r '.body.id' 2>/dev/null)
if [ -z "$USER_ID" ] || [ "$USER_ID" == "null" ]; then
    echo "Warning: Could not extract user ID from response"
    USER_ID="test-user-id"
fi

echo "Created User ID: $USER_ID"
echo ""
sleep 1

# Test 2: List all users
echo "Test 2: List all users"
echo "----------------------"
LIST_RESPONSE=$(curl -s "$API_HOST/api/v1/web/default/users")
echo "Response:"
echo "$LIST_RESPONSE" | jq '.' 2>/dev/null || echo "$LIST_RESPONSE"
echo ""
sleep 1

# Test 3: Get specific user
echo "Test 3: Get user by ID"
echo "----------------------"
GET_RESPONSE=$(curl -s "$API_HOST/api/v1/web/default/users/$USER_ID")
echo "Response:"
echo "$GET_RESPONSE" | jq '.' 2>/dev/null || echo "$GET_RESPONSE"
echo ""
sleep 1

# Test 4: Update user
echo "Test 4: Update user"
echo "-------------------"
UPDATE_RESPONSE=$(curl -s -X PUT "$API_HOST/api/v1/web/default/users/$USER_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Smith",
    "email": "john.smith@example.com",
    "role": "senior-developer"
  }')

echo "Response:"
echo "$UPDATE_RESPONSE" | jq '.' 2>/dev/null || echo "$UPDATE_RESPONSE"
echo ""
sleep 1

# Test 5: Delete user
echo "Test 5: Delete user"
echo "-------------------"
DELETE_RESPONSE=$(curl -s -X DELETE "$API_HOST/api/v1/web/default/users/$USER_ID")
echo "Response:"
echo "$DELETE_RESPONSE" | jq '.' 2>/dev/null || echo "$DELETE_RESPONSE"
echo ""

echo "=========================================="
echo "User Management Tests Complete!"
echo "=========================================="
echo ""

echo "All tests executed. Review responses above for any errors."
echo ""
