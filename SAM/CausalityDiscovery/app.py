from __future__ import print_function
import boto3
from decimal import Decimal
import json
import urllib
import time
import sys
import os
import datetime

table_name = os.environ['TABLE_NAME']
s3_client = boto3.client('s3')
# rekognition_client = boto3.client('rekognition')

print('Loading function')

# def detect_text(bucket,key):
#     response = rekognition_client.detect_text(Image={"S3Object": {"Bucket": bucket, "Name": key}})
#     return response

# def detect_labels(bucket,key):
#     response = rekognition_client.detect_labels(Image={"S3Object": {"Bucket": bucket, "Name": key}})
#     return response

def get_ec2_instances_id(region,access_key,secret_key):
    ec2_conn = boto3.resource('ec2',region_name=region,aws_access_key_id=access_key,aws_secret_access_key=secret_key)
    
    if ec2_conn:
        for instance in ec2_conn.instances.all():
            if instance.state['Name'] == 'running' and instance.security_groups[0]['GroupName'] == 'ElasticMapReduce-master':
                masterInstanceId = instance.instance_id
                print("Master Instance Id is ",masterInstanceId)
        return masterInstanceId
    else:
        print('Region failed', region)
        return None

def send_command_to_master(InstanceId,command,region,access_key,secret_key):
    ssm_client = boto3.client('ssm',region_name=region,aws_access_key_id=access_key,aws_secret_access_key=secret_key)

    print("Ssm run command: ",command)
    response = ssm_client.send_command(InstanceIds=[InstanceId],DocumentName="AWS-RunShellScript",Parameters={'commands': [command]})

    # command_id = response['Command']['CommandId']
    # output = ssm_client.get_command_invocation(CommandId=command_id,InstanceId=InstanceId)
    # if output['Status'] == 'Success':
    #     print('SSM success')

def lambda1_handler(event, context):
    masterInstanceId = get_ec2_instances_id(event['Configurations'][0]['awsRegion'],event['Configurations'][0]['ec2']['accessKey'],event['Configurations'][0]['ec2']['secretKey'])

    send_command_to_master(masterInstanceId,event['Commands']['gitClone'],event['Configurations'][0]['awsRegion'],event['Configurations'][0]['ec2']['accessKey'],event['Configurations'][0]['ec2']['secretKey'])
    send_command_to_master(masterInstanceId,event['Commands']['putHadoopSetting'],event['Configurations'][0]['awsRegion'],event['Configurations'][0]['ec2']['accessKey'],event['Configurations'][0]['ec2']['secretKey'])
    send_command_to_master(masterInstanceId,event['Commands']['putHadoopData'],event['Configurations'][0]['awsRegion'],event['Configurations'][0]['ec2']['accessKey'],event['Configurations'][0]['ec2']['secretKey'])
    print('Setup success, start causality...')

    try:
        send_command_to_master(masterInstanceId,event['Commands']['sparkSubmit'],event['Configurations'][0]['awsRegion'],event['Configurations'][0]['ec2']['accessKey'],event['Configurations'][0]['ec2']['secretKey'])
        return 'Success' 
    except Exception as e:
        print('Spark went wrong, please check spark logs.')
        raise e

def lambda2_handler(event, context):
    print("Connect from dynamodb to s3...")

    # Get the object from the event.
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])

    try:
        # response = detect_text(bucket, key)
        # textDetections = [text['DetectedText'] for text in response['TextDetections']]
        # for text in textDetections:
        #    print("Log text detected: ",text)

        # response = detect_labels(bucket, key)
        # labels = [{label_prediction['Name']: Decimal(str(label_prediction['Confidence']))} for label_prediction in response['Labels']]
        # for label in labels:
        #    print("Log label detected: ",label)

        s3_ob = s3_client.get_object(Bucket=bucket, Key=key)
        json_dict = json.loads(s3_ob['Body'].read())

        ts = time.time()
        timestamp = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')

        # Write to DynamoDB.
        table = boto3.resource('dynamodb').Table(table_name)
        
        item={'id':key, 'DateTime':timestamp, 'Results':json_dict}
        table.put_item(Item=item)
        #table.put_item(Item=json_dict)

        return 'Success'
    except Exception as e:
        print("Error processing object {} from bucket {}. Event {}".format(key, bucket, json.dumps(event, indent=2)))
        raise e
