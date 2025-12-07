# Serverless Application with Apache OpenServerless

Complete serverless application example demonstrating Apache OpenServerless capabilities including functions, APIs, and event-driven architecture.

## Overview

This deployment demonstrates a real-world serverless application with:
- **Multiple serverless functions** in different languages
- **RESTful API endpoints**
- **Event-driven workflows**
- **Database integration**
- **Package management**

## Architecture

```
User Request
    │
    ▼
API Gateway (OpenServerless)
    │
    ├──► GET /users ──► listUsers function ──► Database
    ├──► POST /users ──► createUser function ──► Database
    ├──► GET /users/:id ──► getUser function ──► Database
    ├──► PUT /users/:id ──► updateUser function ──► Database
    ├──► DELETE /users/:id ──► deleteUser function ──► Database
    │
    └──► POST /process ──► processData ──► notify (sequence)
```

## Components

### Functions (Actions)

1. **User Management Functions** (Python)
   - `listUsers` - List all users
   - `getUser` - Get user by ID
   - `createUser` - Create new user
   - `updateUser` - Update existing user
   - `deleteUser` - Delete user

2. **Data Processing Functions** (Node.js)
   - `processData` - Process incoming data
   - `validateData` - Validate data structure
   - `enrichData` - Enrich data with external info

3. **Utility Functions** (Python)
   - `sendNotification` - Send notifications
   - `logEvent` - Log events to storage

### API Endpoints

- `GET /api/users` - List users
- `POST /api/users` - Create user
- `GET /api/users/{id}` - Get user details
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user
- `POST /api/process` - Process data

### Packages

- `user-service` - User management functions
- `data-service` - Data processing functions
- `utils` - Utility functions

## Prerequisites

- Apache OpenServerless installed (see [installs/openserverless](../../installs/openserverless/))
- ops CLI configured
- Access to OpenServerless API

## Quick Start

### Deploy Everything

```bash
# Run the deployment script
bash deploy.sh
```

### Manual Deployment

Follow the steps below for manual deployment.

## Deployment Steps

### 1. Create Packages

```bash
# Create packages for organization
ops package create user-service
ops package create data-service
ops package create utils
```

### 2. Deploy User Management Functions

```bash
# Deploy list users function
ops action create user-service/listUsers functions/listUsers.py --kind python:3.11

# Deploy get user function
ops action create user-service/getUser functions/getUser.py --kind python:3.11

# Deploy create user function
ops action create user-service/createUser functions/createUser.py --kind python:3.11

# Deploy update user function
ops action create user-service/updateUser functions/updateUser.py --kind python:3.11

# Deploy delete user function
ops action create user-service/deleteUser functions/deleteUser.py --kind python:3.11
```

### 3. Deploy Data Processing Functions

```bash
# Deploy validate data function
ops action create data-service/validateData functions/validateData.js --kind nodejs:18

# Deploy process data function
ops action create data-service/processData functions/processData.js --kind nodejs:18

# Deploy enrich data function
ops action create data-service/enrichData functions/enrichData.js --kind nodejs:18
```

### 4. Deploy Utility Functions

```bash
# Deploy notification function
ops action create utils/sendNotification functions/sendNotification.py --kind python:3.11

# Deploy logging function
ops action create utils/logEvent functions/logEvent.py --kind python:3.11
```

### 5. Create Sequences (Function Chains)

```bash
# Create data processing pipeline
ops action create dataProcessingPipeline \
    --sequence data-service/validateData,data-service/processData,data-service/enrichData

# Create user creation workflow
ops action create userCreationWorkflow \
    --sequence user-service/createUser,utils/sendNotification,utils/logEvent
```

### 6. Create API Endpoints

```bash
# User management APIs
ops api create /users GET user-service/listUsers --response-type json
ops api create /users POST user-service/createUser --response-type json
ops api create /users/{id} GET user-service/getUser --response-type json
ops api create /users/{id} PUT user-service/updateUser --response-type json
ops api create /users/{id} DELETE user-service/deleteUser --response-type json

# Data processing API
ops api create /process POST dataProcessingPipeline --response-type json
```

### 7. Create Triggers and Rules (Optional)

```bash
# Create trigger for user events
ops trigger create userEventTrigger

# Create rule to send notification on user creation
ops rule create notifyOnUserCreate userEventTrigger utils/sendNotification
```

## Testing the Application

### Get API Host

```bash
API_HOST=$(ops apihost get)
echo "API Host: $API_HOST"
```

### Test User Management

```bash
# Create a user
curl -X POST "$API_HOST/api/v1/web/default/users" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "role": "developer"
  }'

# List all users
curl "$API_HOST/api/v1/web/default/users"

# Get specific user (replace {id} with actual ID)
curl "$API_HOST/api/v1/web/default/users/123"

# Update user
curl -X PUT "$API_HOST/api/v1/web/default/users/123" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Smith",
    "email": "john.smith@example.com"
  }'

# Delete user
curl -X DELETE "$API_HOST/api/v1/web/default/users/123"
```

### Test Data Processing

```bash
# Process data
curl -X POST "$API_HOST/api/v1/web/default/process" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "type": "order",
      "amount": 99.99,
      "customer": "john@example.com"
    }
  }'
```

### Direct Function Invocation

```bash
# Invoke function directly
ops action invoke user-service/listUsers --result

# Invoke with parameters
ops action invoke user-service/getUser --result --param id 123

# Invoke sequence
ops action invoke dataProcessingPipeline --result --param data '{"test": true}'
```

## Monitoring and Debugging

### View Logs

```bash
# View recent activation logs
ops activation logs --last

# View specific function logs
ops activation logs --last user-service/createUser

# Poll for new activations
ops activation poll
```

### List Activations

```bash
# List all recent activations
ops activation list

# List activations for specific function
ops activation list user-service/createUser
```

### Check Function Status

```bash
# Get function details
ops action get user-service/createUser

# List all actions
ops action list

# List all packages
ops package list
```

## Database Integration

The example includes Redis integration for data persistence:

```python
# In functions, use Redis for storage
import redis

def main(args):
    r = redis.Redis(
        host=args.get('redis_host', 'localhost'),
        port=args.get('redis_port', 6379)
    )

    # Store data
    r.set('user:123', json.dumps(user_data))

    # Retrieve data
    user = json.loads(r.get('user:123'))

    return user
```

## Environment Variables and Secrets

### Set Default Parameters

```bash
# Set default parameters for a package
ops package update user-service --param REDIS_HOST redis.example.com --param REDIS_PORT 6379

# Set default parameters for an action
ops action update user-service/createUser --param DB_HOST localhost
```

### Use Secrets

```bash
# Bind secrets to actions
ops action update user-service/createUser --param DB_PASSWORD $DB_PASSWORD
```

## Scaling and Performance

### Configure Concurrency

```bash
# Set concurrent execution limit
ops action update user-service/createUser --concurrency 100
```

### Set Memory and Timeout

```bash
# Configure memory (MB) and timeout (ms)
ops action update user-service/createUser --memory 512 --timeout 60000
```

## Advanced Features

### Web Actions

```bash
# Make action web-accessible
ops action update utils/sendNotification --web true

# Access web action
curl "$API_HOST/api/v1/web/default/utils/sendNotification"
```

### Async Invocation

```bash
# Invoke function asynchronously
ops action invoke user-service/processLargeData --async
```

### Scheduled Actions (Cron)

```bash
# Create periodic trigger (every hour)
ops trigger create hourlyCleanup --feed /whisk.system/alarms/alarm --param cron "0 * * * *"

# Create rule to run cleanup
ops rule create hourlyCleanupRule hourlyCleanup utils/cleanupOldData
```

## CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Deploy Serverless App
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install ops CLI
        run: curl -sL https://get.openserverless.io | bash

      - name: Configure ops
        run: |
          ops config set apihost ${{ secrets.OPS_APIHOST }}
          ops config set auth ${{ secrets.OPS_AUTH }}

      - name: Deploy functions
        run: bash deploy.sh
```

## Project Structure

```
serverless-app/
├── README.md
├── deploy.sh                      # Deployment script
├── functions/
│   ├── listUsers.py              # List users function
│   ├── getUser.py                # Get user function
│   ├── createUser.py             # Create user function
│   ├── updateUser.py             # Update user function
│   ├── deleteUser.py             # Delete user function
│   ├── validateData.js           # Validate data function
│   ├── processData.js            # Process data function
│   ├── enrichData.js             # Enrich data function
│   ├── sendNotification.py       # Send notification function
│   └── logEvent.py               # Log event function
├── tests/
│   ├── test_users.sh             # User API tests
│   └── test_data.sh              # Data processing tests
└── cleanup.sh                    # Cleanup script
```

## Cleanup

```bash
# Run cleanup script
bash cleanup.sh

# Or manually:
# Delete APIs
ops api delete /users
ops api delete /users/{id}
ops api delete /process

# Delete actions
ops action delete user-service/listUsers
ops action delete user-service/getUser
ops action delete user-service/createUser
ops action delete user-service/updateUser
ops action delete user-service/deleteUser
ops action delete data-service/validateData
ops action delete data-service/processData
ops action delete data-service/enrichData
ops action delete utils/sendNotification
ops action delete utils/logEvent

# Delete packages
ops package delete user-service
ops package delete data-service
ops package delete utils
```

## Best Practices

1. **Function Design**
   - Keep functions small and focused
   - Use packages for organization
   - Set appropriate timeouts and memory limits

2. **Error Handling**
   - Implement proper error handling in functions
   - Return meaningful error messages
   - Log errors for debugging

3. **Security**
   - Use secrets for sensitive data
   - Implement authentication for APIs
   - Validate input data

4. **Performance**
   - Use appropriate concurrency settings
   - Optimize function code
   - Use caching where appropriate

5. **Monitoring**
   - Implement logging in all functions
   - Monitor activation metrics
   - Set up alerts for failures

## Troubleshooting

### Function Not Responding

```bash
# Check activation logs
ops activation logs --last

# Check function configuration
ops action get user-service/createUser

# Test function directly
ops action invoke user-service/createUser --result --param test true
```

### API Not Accessible

```bash
# List all APIs
ops api list

# Verify API configuration
ops api get /users
```

### High Latency

```bash
# Check activation statistics
ops activation list --limit 10

# Increase memory allocation
ops action update user-service/createUser --memory 512
```

## Next Steps

- Add authentication and authorization
- Implement database persistence (PostgreSQL, MongoDB)
- Add monitoring and alerting
- Implement CI/CD pipeline
- Add integration tests
- Scale to production workloads
- Explore other deployment patterns

## Resources

- [OpenServerless Documentation](https://openserverless.apache.org/docs/)
- [OpenServerless Installation](../../installs/openserverless/)
- [Tutorial: First Steps](https://openserverless.apache.org/docs/tutorial/first-steps/)
- [API Reference](https://openserverless.apache.org/docs/reference/)
