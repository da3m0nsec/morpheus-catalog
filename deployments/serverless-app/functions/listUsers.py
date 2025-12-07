"""
List all users from the database
"""
import json
import redis
import os

def main(args):
    """
    List all users stored in Redis

    Returns:
        dict: List of all users with their details
    """
    try:
        # Get Redis connection details from args or environment
        redis_host = args.get('REDIS_HOST', os.environ.get('REDIS_HOST', 'localhost'))
        redis_port = int(args.get('REDIS_PORT', os.environ.get('REDIS_PORT', 6379)))

        # Connect to Redis
        r = redis.Redis(
            host=redis_host,
            port=redis_port,
            decode_responses=True
        )

        # Get all user keys
        user_keys = r.keys('user:*')

        # Retrieve all users
        users = []
        for key in user_keys:
            user_data = r.get(key)
            if user_data:
                user = json.loads(user_data)
                users.append(user)

        return {
            'statusCode': 200,
            'body': {
                'users': users,
                'count': len(users)
            }
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
