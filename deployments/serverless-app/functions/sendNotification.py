"""
Send notification (email, SMS, webhook)
"""
import json
from datetime import datetime

def main(args):
    """
    Send notification based on event

    Args:
        args: Dictionary containing notification details

    Returns:
        dict: Notification status
    """
    try:
        # Get notification details
        notification_type = args.get('type', 'email')
        recipient = args.get('recipient')
        message = args.get('message')
        subject = args.get('subject', 'Notification from Serverless App')

        if not recipient:
            return {
                'statusCode': 400,
                'body': {
                    'error': 'Bad request',
                    'message': 'recipient is required'
                }
            }

        if not message:
            return {
                'statusCode': 400,
                'body': {
                    'error': 'Bad request',
                    'message': 'message is required'
                }
            }

        # Simulate sending notification
        # In production, this would integrate with email service, SMS gateway, etc.
        notification = {
            'id': f'NOTIF-{datetime.utcnow().timestamp()}',
            'type': notification_type,
            'recipient': recipient,
            'subject': subject,
            'message': message,
            'status': 'sent',
            'sent_at': datetime.utcnow().isoformat()
        }

        # Log the notification (in production, this would actually send)
        print(f"[NOTIFICATION] {notification_type} to {recipient}")
        print(f"Subject: {subject}")
        print(f"Message: {message}")

        return {
            'statusCode': 200,
            'body': {
                'message': 'Notification sent successfully',
                'notification': notification
            }
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': {
                'error': 'Failed to send notification',
                'message': str(e)
            }
        }
