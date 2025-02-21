# STEP 3: Get EC2 Username and Public IP
output "server_ssh_access" {
  description = "Command to SSH into the EC2 instance."
  value       = "ubuntu@${aws_instance.my-ec2.public_ip}"
}

# STEP 4: Get EC2 Public IP
output "public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.my-ec2.public_ip
}

# STEP 5: Get EC2 Private IP
output "private_ip" {
  description = "Private IP address of the EC2 instance."
  value       = aws_instance.my-ec2.private_ip
}
