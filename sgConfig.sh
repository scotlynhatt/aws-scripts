#!/bin/bash 

# If you do not have MFA or a profile for your CLI machine
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

# If you have an IAM profile attached to your AWS based CLI server, you can use the following to establish credentials
#instance_profile="$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/)"
#export AWS_ACCESS_KEY_ID="$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/${instance_profile} | grep AccessKeyId | cut -d':' -f2 | sed 's/[^0-9A-Z]*//g')"
#export AWS_SECRET_ACCESS_KEY="$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/${instance_profile} | grep SecretAccessKey | cut -d':' -f2 | sed 's/[^0-9A-Za-z/+=]*//g')"
#export AWS_SESSION_TOKEN="$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/${instance_profile} | sed -n '/Token/{p;}' | cut -f4 -d'\"')"

# This opens up some servers to SSH access from a bastion or NAT. I could be modified to connect a bunch of systems to the bastion. 
# This is useful if you scripted the EC2 creation and did not pre-configure the SGs
INSTANCES=(
"Server-1"
"Server-2"
"Server-3"
)

for instance in "${INSTANCES[@]}"; do
	if [ "${instance}" == "Server-1" ]; then
		# DevOps-SG
		# Open SSH access from Bastion
		aws ec2 authorize-security-group-ingress --group-id ${instance}-SG --protocol tcp --port 22 --source-group sg-0f0f0f0f
		# Open SSH access from NAT
		aws ec2 authorize-security-group-ingress --group-id ${instance}-SG --protocol tcp --port 22 --source-group sg-ffffffff
	fi
	
done
