"""
Get a specific user by ID
"""
import json
import redis
import os

def main(args):
    """
    Get a specific user by ID

    Args:
        args: Dictionary containing user_id

    Returns:
        dict: User details or error message
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

        # Get user data
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
