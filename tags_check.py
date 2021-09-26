import boto3
region = 'us-east-1'

ec2 = boto3.resource('ec2')
volume_ids = [volume.id for volume in ec2.volumes.all()]

ec2client = boto3.client('ec2',region_name=region)

def lambda_handler(event, context):
    for vid in volume_ids:
        volume = ec2client.volume(vid)
        inst = ec2client.instance(volume.attachments[0]["InstanceId"])
        tags = volume.create_tags(Tags = inst.tags)
    return tags


