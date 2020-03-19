#!/usr/bin/env python3

import boto3
import botocore
import jinja2
import os
import sys
import yaml
import glob


def main():
    if 'AWS_PROFILE' in os.environ:
        boto3.setup_default_session(profile_name=os.environ['AWS_PROFILE'])
    if 'AWS_REGION' in os.environ:
        ssm = boto3.client('ssm', region_name=os.environ['AWS_REGION'])
    else:
        ssm = boto3.client('ssm')

    try:
        parameter = ssm.get_parameter(Name='terraform_bootstrap_config', WithDecryption=False)
    except botocore.exceptions.ClientError as e:
        error_message = e.response["Error"]["Message"]
        if "The security token included in the request is invalid" in error_message:
            print("ERROR: Invalid security token used when calling AWS SSM. Have you run `aws-sts` recently?")
        else:
            print("ERROR: Problem calling AWS SSM: {}".format(error_message))
        sys.exit(1)

    config_data = yaml.load(parameter['Parameter']['Value'], Loader=yaml.FullLoader)
    
    j2_files = glob.glob('**/*.j2', recursive=True)

    for template_path in j2_files:
        out_path = template_path.replace('.j2', '')
        with open(template_path) as in_template:
            template = jinja2.Template(in_template.read())
        with open(out_path, 'w+') as out_file:
            out_file.write(template.render(config_data))

    print("Terraform config successfully created")


if __name__ == "__main__":
    main()

