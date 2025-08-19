import json
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Received budget notification: %s", json.dumps(event))

    # Optional: Stop EC2 instances
    ec2 = boto3.client('ec2')
    response = ec2.describe_instances(
        Filters=[{
            'Name': 'tag:AutoShutdown',
            'Values': ['true']
        }]
    )

    instances_to_stop = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instances_to_stop.append(instance['InstanceId'])

    if instances_to_stop:
        logger.info("Stopping instances: %s", instances_to_stop)
        ec2.stop_instances(InstanceIds=instances_to_stop)

    return {
        'statusCode': 200,
        'body': json.dumps('Remediation complete.')
    }
