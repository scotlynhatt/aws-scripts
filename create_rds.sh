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

# Change for your env
DB_SG="sg-ffffffff"
RDS_INSTANCES=(
"db-1,postgres,9.5,5432,MyDB1,100,db.t2.large,default:postgres-9-5,dbadmin,P@$sw0rd!,${DB_SG},${AWS_DEFAULT_REGION},${AWS_DEFAULT_REGION}a,GMT"
"db-2,postgres,9.5,5432,MyDB2,100,db.t2.large,default:postgres-9-5,dbadmin,P@$sw0rd!,${DB_SG},${AWS_DEFAULT_REGION},${AWS_DEFAULT_REGION}a,GMT"
"db-3,postgres,9.5,5432,MyDB3,100,db.t2.large,default:postgres-9-5,dbadmin,P@$sw0rd!,${DB_SG},${AWS_DEFAULT_REGION},${AWS_DEFAULT_REGION}a,GMT"
)

# no changes needed unless AWS API has changed
for rds in "${RDS_INSTANCES[@]}"; do
    while IFS=',' read -ra KEYVALUE; do
		aws rds create-db-instance --db-name ${KEYVALUE[0]} --engine ${KEYVALUE[1]} \
		--engine-version ${KEYVALUE[2]} --port ${KEYVALUE[3]} \
		--db-instance-identifier ${KEYVALUE[4]} --allocated-storage ${KEYVALUE[5]} \
		--db-instance-class ${KEYVALUE[6]} --db-subnet-group-name ${KEYVALUE[7]} \
		--master-username ${KEYVALUE[8]} --master-user-password ${KEYVALUE[9]} \
		--vpc-security-group-ids ${KEYVALUE[10]} --region ${KEYVALUE[11]} \
		--availability-zone ${KEYVALUE[12]}  --timezone ${KEYVALUE[13]}
    done <<< "$instance"
done

