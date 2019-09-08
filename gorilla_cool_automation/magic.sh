#!/bin/bash

export AWS_DEFAULT_REGION=us-east-1

CFN_BUCKET=cfn-templates-gorilla
STACK_NAME=timeoff-app
REPO_NAME=$STACK_NAME
KEY_NAME=timeoff-key

# Create the ssh key
ls $KEY_NAME >/dev/null 2>&1 || ssh-keygen -f $KEY_NAME -N "" -m PEM -t rsa
# Import it in aws if it's not there
aws ec2 describe-key-pairs --key-name  $KEY_NAME >/dev/null 2>&1 || aws ec2 import-key-pair --key-name $KEY_NAME --public-key-material file://$PWD/$KEY_NAME.pub
# Bucket to upload cfn files!
aws s3 ls $CFN_BUCKET >/dev/null 2>&1 || aws s3api create-bucket --bucket $CFN_BUCKET
# Version it
aws s3api put-bucket-versioning --bucket $CFN_BUCKET --versioning-configuration Status=Enabled
# Upload files
echo "Uploading cfn templates to s3" && aws s3 sync ./cfn s3://$CFN_BUCKET

aws cloudformation deploy --template-file ./cfn/master.yaml \
	--stack-name $STACK_NAME       \
	--parameter-overrides          \
		VpcCIDR=10.100.0.0/16      \
		Subnet1CIDR=10.100.10.0/24 \
		Subnet2CIDR=10.100.20.0/24 \
		TargetBranch=master        \
		TemplateBucket=$CFN_BUCKET \
		RepoName=$REPO_NAME        \
		AMI=ami-0c09d65d2051ada93  \
		InstanceType=t2.micro      \
		MaxSize=2                  \
		KeyPairName=$KEY_NAME      \
		DesiredCapacity=2          \
		EcsDesiredCount=2          \
	--tags App=$STACK_NAME --capabilities CAPABILITY_IAM
