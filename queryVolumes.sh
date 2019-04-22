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

QUERY="*"
LAYOUTS=()
INSTANCES=$(aws ec2 describe-instances --filters Name=tag-value,Values="${QUERY}" --output text --query 'Reservations[].Instances[].InstanceId' | awk '{print "\"" $1 "\""}')

echo -e "${#INSTANCES[@]} instance count"

for instance in "${INSTANCES[@]}"; do
        LAYOUTS+=("$(aws ec2 describe-instances --instance-ids $instance --output text --query 'Reservations[*].Instances[*].[[InstanceId,Tags[?Key==`Name`].Value[],BlockDeviceMappings[].DeviceName]]' --region ${AWS_DEFAULT_REGION}| tr '[[:space:]]' ':' | awk '{print "\"" $1 "\""}' |sed 's/:"/"/g') ")
done

for layout in "${LAYOUTS[@]}"; do
	echo $layout
done