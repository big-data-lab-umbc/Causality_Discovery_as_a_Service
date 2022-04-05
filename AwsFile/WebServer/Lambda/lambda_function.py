import boto3
import json
import time
import sys
import os

print('Loading function')
s3 = boto3.resource('s3')

bucket =  'CDaaS-object-data-storage' 
credentials = ["us-west-2","AKIASHT77xxxxxxxxxx","36E3p9vvc1TtscMxxxxxxxxxxxxxxxx"]   #region,access_key,secret_key
InstanceId = 'i-0aadf5b8465b15d87'    #use your instanceID of CDaaS master node


def send_command_to_master(InstanceId,command,ssm_client):
    print("Ssm run command: ",command)
    response = ssm_client.send_command(InstanceIds=[InstanceId],DocumentName="AWS-RunShellScript",Parameters={'commands': [command]})

    
def s3_put_object(filename,path):
    return "aws s3 sync /home/ubuntu/%s s3://%s"%(filename,path) 
    
    
def respond(err, res=None):
    return {
        'statusCode': '400' if err else '200',
        'body': err.message if err else res,
        'headers': {
            'Content-Type': 'application/json',
        },
    }


def lambda_handler(event, context):
    ssm_client = boto3.client('ssm',region_name=credentials[0],aws_access_key_id=credentials[1],aws_secret_access_key=credentials[2])
  
    operation = event['httpMethod']
    if operation == 'GET':
        key = json.loads(event['body'])['filename']     #'CDaaS_result.txt' 
        return_url = "https://" + bucket + ".s3.us-west-2.amazonaws.com/" + key
        
        return respond(None, return_url)
    elif operation == 'POST': 
        command = json.loads(event['body'])['command']  
        
        # run command in ec2
        send_command_to_master(InstanceId,\
            command,\
            ssm_client)
        
        return {
            'statusCode': 200,
            'body': json.dumps('Your command is running in CDaaS cluster.')
        }
        
