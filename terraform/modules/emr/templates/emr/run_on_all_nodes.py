# Install Python libraries on running cluster nodes
import json
import sys
from boto3 import client

emrclient = client('emr')

# Get list of core nodes
with open('/mnt/var/lib/info/extraInstanceData.json') as json_file:
    data = json.load(json_file)
    clusterId = data["jobFlowId"]
script = "${emr_bucket_path}/${script_path}"

instances = emrclient.list_instances(ClusterId=clusterId, InstanceGroupTypes=['CORE'])['Instances']
instance_list = [x['Ec2InstanceId'] for x in instances]

# Attach tag to core nodes
ec2client = client('ec2')
ec2client.create_tags(Resources=instance_list, Tags=[{"Key": "environment", "Value": "coreNodeLibs"}])

ssmclient = client('ssm')

# Download shell script from S3
command = "aws s3 cp " + script + " /home/hadoop"
try:
    first_command = ssmclient.send_command(Targets=[{"Key": "tag:environment", "Values": ["coreNodeLibs"]}],
                                           DocumentName='AWS-RunShellScript',
                                           Parameters={"commands": [command]},
                                           TimeoutSeconds=3600)['Command']['CommandId']

    # Wait for command to execute
    import time

    time.sleep(15)

    first_command_status = ssmclient.list_commands(
        CommandId=first_command,
        Filters=[
            {
                'key': 'Status',
                'value': 'SUCCESS'
            },
        ]
    )['Commands'][0]['Status']

    second_command = ""
    second_command_status = ""

    # Only execute second command if first command is successful

    if first_command_status == 'Success':
        # Run shell script to install libraries

        second_command = ssmclient.send_command(Targets=[{"Key": "tag:environment", "Values": ["coreNodeLibs"]}],
                                                DocumentName='AWS-RunShellScript',
                                                Parameters={"commands": [f"bash /home/hadoop/{script}"]},
                                                TimeoutSeconds=3600)['Command']['CommandId']

        second_command_status = "PENDING"
        while second_command_status != "SUCCESS":
            second_command_status = ssmclient.list_commands(
                CommandId=second_command,
                Filters=[
                    {
                        'key': 'Status',
                        'value': 'SUCCESS'
                    },
                ]
            )['Commands'][0]['Status']
            time.sleep(30)
            if second_command_status == "FAILED":
                sys.exit(1)

        print("First command, " + first_command + ": " + first_command_status)
        print("Second command:" + second_command + ": " + second_command_status)

except Exception as e:
    print(e)
