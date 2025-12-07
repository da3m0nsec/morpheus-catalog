"""
Log events to storage
"""
import json
from datetime import datetime
import os

def main(args):
    """
    Log event to storage system

    Args:
        args: Dictionary containing event details

    Returns:
        dict: Log entry confirmation
    """
    try:
        # Get event details
        event_type = args.get('event_type', 'generic')
        event_data = args.get('data', {})
        severity = args.get('severity', 'info')
        source = args.get('source', 'serverless-app')

        # Create log entry
        log_entry = {
            'id': f'LOG-{datetime.utcnow().timestamp()}',
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            'severity': severity,
            'source': source,
            'data': event_data,
            'environment': os.environ.get('ENV', 'production')
        }

        # In production, this would write to a logging service
        # (e.g., CloudWatch, Elasticsearch, Splunk, etc.)
        print(f"[LOG] {severity.upper()}: {event_type}")
        print(json.dumps(log_entry, indent=2))

        # Simulate storage
        storage_result = {
            'stored': True,
            'storage_id': log_entry['id'],
            'location': 'event-logs',
            'indexed': True
        }

        return {
            'statusCode': 200,
            'body': {
                'message': 'Event logged successfully',
                'log_entry': log_entry,
                'storage': storage_result
            }
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': {
                'error': 'Failed to log event',
                'message': str(e)
            }
        }
