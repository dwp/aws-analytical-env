import json
import boto3
import os
from datetime import datetime
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    userPoolId = os.environ['USERPOOLID']
    region     = os.environ['REGION']
    bucketName = os.environ['BUCKETNAME']
    kmsKey     = os.environ['KMS_KEY']

    if userPoolId is None or region is None or bucketName is None or kmsKey is None:
        logger.error('Missing environment variables.')
        raise Exception('Missing environment variables')

    if event['detail']['requestParameters']['userPoolId'] != userPoolId:
        return {'statusCode':200 }
    
    session = boto3.Session(region_name = region)
                             
    client = session.client('cognito-idp')
    
    users = client.list_users(
        UserPoolId = userPoolId)

    groups = client.list_groups(
        UserPoolId = userPoolId)
    
    groupInfo = {}
    for g in groups['Groups']:
        groupInfo[g['GroupName']] = []
        usersInGroup = client.list_users_in_group(
            UserPoolId = userPoolId,
            GroupName = g['GroupName'])
            
        for user in usersInGroup['Users']:
            groupInfo[g['GroupName']].append(user['Username'])
            
    information = { 'users': users['Users'], 'groupInfo': groupInfo, 'eventName': event['detail']['eventName'] }
    
    s3Client = boto3.client('s3');
    filename = 'CognitoSnapshots/snapshot_' + datetime.now().strftime("%Y-%m-%d-%H%M%S") + '.json'
    
    
    s3Client.put_object(Body=json.dumps(information, indent=2, sort_keys=True, default=str), Bucket=bucketName, Key=filename, ServerSideEncryption='aws:kms', SSEKMSKeyId=kmsKey)
    
    return {
        'statusCode': 200,
        'body': {}
    }
