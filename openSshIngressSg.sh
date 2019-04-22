#!/bin/bash

# Change a bunch of Security Groups to allow SSH ingress. Can be modified to open other things.

# If you do not have MFA or a profile for your CLI machine
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

# If you have an IAM profile attached to your AWS based CLI server, you can use the following to establish credentials
#instance_profile="$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/)"
#export AWS_ACCESS_KEY_ID="$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/${instance_profile} | grep AccessKeyId | cut -d':' -f2 | sed 's/[^0-9A-Z]*//g')"
#export AWS_SECRET_ACCESS_KEY="$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/${instance_profile} | grep SecretAccessKey | cut -d':' -f2 | sed 's/[^0-9A-Za-z/+=]*//g')"
#export AWS_SESSION_TOKEN="$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/${instance_profile} | sed -n '/Token/{p;}' | cut -f4 -d'\"')"

# Change to valid SGs
SG=(
sg-00000000
sg-00000001
sg-00000002
)

for sgid in "${SG[@]}";do
	# The CIDR here is for a private network. Prolly not a good idea to open up SSH to the world on Internet facing instances.
	aws ec2 authorize-security-group-ingress --group-id $sgid --protocol tcp --port 22 --cidr 0.0.0.0/0
	# Add more ports if needed
done
