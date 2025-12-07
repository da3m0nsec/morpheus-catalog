#!/bin/bash
#
# Test Data Processing Pipeline
#

set -e

echo "=========================================="
echo "Testing Data Processing Pipeline"
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

# Test 1: Process order data
echo "Test 1: Process order data"
echo "--------------------------"
ORDER_RESPONSE=$(curl -s -X POST "$API_HOST/api/v1/web/default/process" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "type": "order",
      "amount": 99.99,
      "customer": "john@example.com"
    }
  }')

echo "Response:"
echo "$ORDER_RESPONSE" | jq '.' 2>/dev/null || echo "$ORDER_RESPONSE"
echo ""
sleep 1

# Test 2: Process user data
echo "Test 2: Process user data"
echo "-------------------------"
USER_RESPONSE=$(curl -s -X POST "$API_HOST/api/v1/web/default/process" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "type": "user",
      "name": "Jane Smith",
      "email": "jane@example.com"
    }
  }')

echo "Response:"
echo "$USER_RESPONSE" | jq '.' 2>/dev/null || echo "$USER_RESPONSE"
echo ""
sleep 1

# Test 3: Invalid data (should fail validation)
echo "Test 3: Invalid data (should fail)"
echo "-----------------------------------"
INVALID_RESPONSE=$(curl -s -X POST "$API_HOST/api/v1/web/default/process" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "type": "order"
    }
  }')

echo "Response:"
echo "$INVALID_RESPONSE" | jq '.' 2>/dev/null || echo "$INVALID_RESPONSE"
echo ""
sleep 1

# Test 4: Direct function invocation - validateData
echo "Test 4: Direct function invocation"
echo "-----------------------------------"
echo "Invoking validateData function directly..."
ops action invoke data-service/validateData --result --param data '{"type":"order","amount":150,"customer":"test@example.com"}'
echo ""

# Test 5: Direct function invocation - processData
echo "Test 5: Invoke processData directly"
echo "------------------------------------"
ops action invoke data-service/processData --result --param data '{"type":"order","amount":150,"customer":"test@example.com"}'
echo ""

# Test 6: Direct function invocation - enrichData
echo "Test 6: Invoke enrichData directly"
echo "-----------------------------------"
ops action invoke data-service/enrichData --result --param data '{"type":"order","amount":150,"customer":"test@example.com","total":162}'
echo ""

echo "=========================================="
echo "Data Processing Tests Complete!"
echo "=========================================="
echo ""

echo "All tests executed. Review responses above for validation, processing, and enrichment."
echo ""
