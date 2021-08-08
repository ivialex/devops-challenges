from ec2_management import *

# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    all_info = get_list_fields_all_server()
    print(all_info)
