# DEFINE ALL YOUR VARIABLES HERE

instance_type = "t3.large"
ami           = "ami-09a9858973b288bdd" # Ubuntu 24.04
key_name      = "projectkey"            # Replace with your key-name without .pem extension
volume_size   = 30
region_name   = "eu-north-1"
server_name   = "jenkins-serv"

# Note: 
# a. First create a pem-key manually from the AWS console
# b. Copy it in the same directory as your terraform code
