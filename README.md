#Python Source Code with PrettyTable
Follow the steps below to test the application.

##Creating Virtual Environments
>python3 -m venv venv/

##Active your virtual environment:
>source venv/bin/activate

##Environment Variables
Change the following environment variables in the `.env` file in the source folder:
- KEY_ID  
- SECRET_KEY  
- REGION_NAME  

##Prerequisites
Install all necessary libraries or packages by running the following command:  
> pip install -r source/requirements.txt

##Execution 
To run the program, just run the following command:
> cd source
> python main.py

#Terraform and AWS Lambda Function
Follow the steps below to test the application.

##Environment Variables
Change the following environment variables in the `terraform.tfvars` file in the terraform folder:
- aws_access_key  
- aws_secret_key  
- aws_region  

##Creating the resources in AWS by Terraform 
> cd terraform
> terraform init
> terraform plan
> terraform apply

##Execution 
To run the program, just run the following command:
> curl "$(terraform output -raw base_url)/list"

