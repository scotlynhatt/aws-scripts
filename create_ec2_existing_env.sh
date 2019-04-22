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

# Change all the stuff to your configruation
AMI="--image-id ami-12345678"
REGION="--region us-east-1"
SUBNET="--subnet-id subnet-ffffffff"
INSTANCE_PROFILE="--iam-instance-profile Name=MyAWSProfile"
COMMON="--key-name MyKey ${AMI} ${REGION} ${SUBNET} ${REGION} ${INSTANCE_PROFILE}"
VOL_SIZE="80"
INSTANCE_TYPE="t2.large"

# As many as you want. Change Security Groups to match env
INSTANCES=( 
"Server-1:sg-ffffffff"
"Server-2:sg-ffffffff"
"Server-3:sg-00000000"
"Server-4:sg-00000000"
)

for instance in "${INSTANCES[@]}"; do
	while IFS=':' read -ra KEYVALUE; do
		ID=`aws ec2 run-instances ${COMMON} --instance-type ${INSTANCE_TYPE} --count 1 \
		--security-group-ids ${KEYVALUE[1]} --no-associate-public-ip-address \
		--block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": ${VOL_SIZE} } } ]" \
		--output text --query 'Instances[*].InstanceId'`
		aws ec2 create-tags --resources ${ID} --tags Key=Name,Value=${KEYVALUE[0]} ${REGION} VOLUME=`aws ec2 describe-instances --instance-ids ${ID} --output text --query 'Reservations[0].Instances[0].[BlockDeviceMappings[0].[Ebs.VolumeId]]' ${REGION}`
		aws ec2 create-tags --resources ${VOLUME} --tags Key=Name,Value=${KEYVALUE[0]}-EBS ${REGION}
	done <<< "$instance"
done

