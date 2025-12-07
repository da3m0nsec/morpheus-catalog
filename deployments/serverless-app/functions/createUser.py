"""
Create a new user
"""
import json
import redis
import os
from datetime import datetime
import uuid

def main(args):
    """
    Create a new user in the database

    Args:
        args: Dictionary containing name, email, role

    Returns:
        dict: Created user details or error message
    """
    try:
        # Validate required fields
        name = args.get('name')
        email = args.get('email')
        role = args.get('role', 'user')

        if not name or not email:
            return {
                'statusCode': 400,
                'body': {
                    'error': 'Bad request',
                    'message': 'name and email are required'
                }
            }

        # Validate email format (basic)
        if '@' not in email:
            return {
                'statusCode': 400,
                'body': {
                    'error': 'Bad request',
                    'message': 'Invalid email format'
                }
            }

        # Get Redis connection details
        redis_host = args.get('REDIS_HOST', os.environ.get('REDIS_HOST', 'localhost'))
        redis_port = int(args.get('REDIS_PORT', os.environ.get('REDIS_PORT', 6379)))

        # Connect to Redis
        r = redis.Redis(
            host=redis_host,
            port=redis_port,
            decode_responses=True
        )

        # Generate unique user ID
        user_id = str(uuid.uuid4())

        # Create user object
        user = {
            'id': user_id,
            'name': name,
            'email': email,
            'role': role,
            'created_at': datetime.utcnow().isoformat(),
            'updated_at': datetime.utcnow().isoformat()
        }

        # Store user in Redis
        user_key = f'user:{user_id}'
        r.set(user_key, json.dumps(user))

        # Also index by email for uniqueness check
        email_key = f'email:{email}'
        r.set(email_key, user_id)

        return {
            'statusCode': 201,
            'body': user
        }

    except redis.ConnectionError as e:
        return {
            'statusCode': 500,
            'body': {
                'error': 'Database connection failed',
                'message': str(e)
            }
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': {
                'error': 'Internal server error',
                'message': str(e)
            }
        }
