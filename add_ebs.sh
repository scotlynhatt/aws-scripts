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

# This is good for adding an identical volume to your whol inventory
AZ="us-east-1a"
VOL_SIZE="100"
VOL_TYPE="gp2"
VOL_LABEL="Docker-EBS"
VOL_DEV="/dev/sdf"

INSTANCES=(
"i-01234567890123456:My-Server-01"
"i-01234567891123456:My-Server-02"
"i-01234567892123456:My-Server-03"
"i-01234567893123456:My-Server-04"
)

for instance in "${INSTANCES[@]}"; do
	while IFS=':' read -ra KEYVALUE; do
		VOLUME=`aws ec2 create-volume --availability-zone ${AZ} --region ${AWS_DEFAULT_REGION} --volume-type ${VOL_TYPE} --size ${VOL_SIZE} --output text --query 'VolumeId' --tag-specifications 'ResourceType=volume,Tags=[{Key="Name",Value="${KEYVALUE[1]}-${VOL_LABEL}"}]'`
		
		aws ec2 create-tags --resources ${VOLUME} --tags Key=Name,Value=${KEYVALUE[1]}-${VOL_LABEL} --region ${AWS_DEFAULT_REGION}
		
		# Let it finish
		sleep 5
		
		aws ec2 attach-volume --instance-id ${KEYVALUE[0]} --volume-id ${VOLUME} --device ${VOL_DEV}
	done <<< "$instance"
done
