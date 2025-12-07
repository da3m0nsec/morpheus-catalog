"""
Update an existing user
"""
import json
import redis
import os
from datetime import datetime

def main(args):
    """
    Update an existing user

    Args:
        args: Dictionary containing user_id and fields to update

    Returns:
        dict: Updated user details or error message
    """
    try:
        # Validate input
        user_id = args.get('id') or args.get('user_id')
        if not user_id:
            return {
                'statusCode': 400,
                'body': {
                    'error': 'Bad request',
                    'message': 'user_id is required'
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

        # Get existing user
        user_key = f'user:{user_id}'
        user_data = r.get(user_key)

        if not user_data:
            return {
                'statusCode': 404,
                'body': {
                    'error': 'Not found',
                    'message': f'User with id {user_id} not found'
                }
            }

        user = json.loads(user_data)

        # Update fields if provided
        if 'name' in args:
            user['name'] = args['name']
        if 'email' in args:
            # Validate email format
            if '@' not in args['email']:
                return {
                    'statusCode': 400,
                    'body': {
                        'error': 'Bad request',
                        'message': 'Invalid email format'
                    }
                }
            user['email'] = args['email']
        if 'role' in args:
            user['role'] = args['role']

        # Update timestamp
        user['updated_at'] = datetime.utcnow().isoformat()

        # Save updated user
        r.set(user_key, json.dumps(user))

        return {
            'statusCode': 200,
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
