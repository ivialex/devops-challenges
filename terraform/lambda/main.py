import json
from ec2_management import *
    
def lambda_handler(event, context):
    all_info = get_list_fields_all_server()
    return {
        'statusCode': 200,
        'body': json.dumps(all_info)
    }
