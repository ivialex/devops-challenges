"""
Purpose

Shows how to use AWS SDK for Python (Boto3) with the Amazon Elastic Compute Cloud
(Amazon EC2) API to manage aspects of an Amazon EC2 instance.
"""

import logging
import operator
import os

import boto3
from botocore.exceptions import ClientError
from prettytable import PrettyTable
from dotenv import load_dotenv
from pathlib import Path
logger = logging.getLogger(__name__)


def get_list_fields_by_server(instance_id):
    """
    Given the EC2 instance ID, will return a table with a list of fields for each server:
    instance-id, instance-type, status, private-ip, public-ip (if available), total-size-ebs-volumes (so
    the sum of the sizes in GB of the attached volumes to the instance)
    :param instance_id: The ID of the instance.
    :return: table with a list of fields for each server.
    """
    try:
        env_path = Path('.', '.env')
        load_dotenv(dotenv_path=env_path)
        client = boto3.client('ec2',
                              aws_access_key_id=os.getenv('KEY_ID'),
                              aws_secret_access_key=os.getenv('SECRET_KEY'),
                              region_name=os.getenv('REGION_NAME'))

        ec2_info = client.describe_instances(
             InstanceIds=[
                 instance_id,
             ]
        ).get('Reservations', [])[0].get('Instances',[])

        instance_type = ec2_info[0].get("InstanceType")
        status = ec2_info[0].get("State").get("Name")
        private_ip = ec2_info[0].get("PrivateIpAddress")
        public_ip = ec2_info[0].get("PublicIpAddress")

        volumes = client.describe_volumes(
            Filters=[{'Name': 'attachment.instance-id', 'Values': [instance_id]}]
        )

        vol_total_size = 0

        for disk in volumes['Volumes']:
            vol_total_size += disk['Size']

        ec2_table = PrettyTable(['InstanceID', 'InstanceType', 'Status', 'PrivateIP', 'PublicIP', 'TotalSizeEBSVolumes'])
        ec2_table.add_row([instance_id, instance_type, status, private_ip, public_ip, vol_total_size])

        logger.info("Got Info for instance %s.", instance_id)

    except ClientError:
        logger.exception(("Couldn't get info for instance %s.", instance_id))
        raise
    else:
        return ec2_table


def get_list_fields_all_server():
    """
    Given the EC2 instance ID, will return a table with a list of fields for each server:
    instance-id, instance-type, status, private-ip, public-ip (if available), total-size-ebs-volumes (so
    the sum of the sizes in GB of the attached volumes to the instance)
    :return: table with a list of fields for each server.
    """
    try:
        env_path = Path('.', '.env')
        load_dotenv(dotenv_path=env_path)
        client = boto3.client('ec2',
                              aws_access_key_id=os.getenv('KEY_ID'),
                              aws_secret_access_key=os.getenv('SECRET_KEY'),
                              region_name=os.getenv('REGION_NAME'))

        all_instances = client.describe_instances()
        instances = []
        vol_total_size_all_instances = 0

        for reservation in all_instances['Reservations']:
            for instance in reservation['Instances']:
                instance_type = instance.get("InstanceType")
                status = instance.get("State").get("Name")
                private_ip = instance.get("PrivateIpAddress")
                public_ip = instance.get("PublicIpAddress")
                instance_id = instance.get("InstanceId")

                volumes = client.describe_volumes(
                    Filters=[{'Name': 'attachment.instance-id', 'Values': [instance.get("InstanceId")]}]
                )

                vol_total_size = 0

                for disk in volumes['Volumes']:
                    vol_total_size += disk['Size']

                vol_total_size_all_instances += vol_total_size

                ec2_info = {"InstanceId": instance_id,
                            "InstanceType": instance_type,
                            "Status": status,
                            "PrivateIP": private_ip,
                            "PublicIP": public_ip,
                            "TotalSizeEBSVolumes": vol_total_size}

                instances.append(ec2_info)

        instances.sort(key=operator.itemgetter('TotalSizeEBSVolumes'))
        instances.append({"TotalVolumesAllInstances": vol_total_size_all_instances})

    except ClientError:
        logger.exception("Couldn't get info for all instances.")
        raise
    else:
        return instances
