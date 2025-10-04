#!/bin/bash

##########################################################################
# ========================= AWS Resource Tracker =========================
#
# Author : Vedansh kumar
# Date   : 2024-06-15
# Version: 1.0
#
# Description : This script will report the AWS usage of various resources
#               like :- AWS EC2, AWS S3, IAM users, Lambda functions etc
#
##########################################################################
#
# testing (change to set -xeou pipefail for testing)
# safe defaults; add -x while debugging: set -euo pipefail; set -x
set +euo pipefail

# Check if the AWS CLI is installed or not
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please configure it and try again"
    exit 1
fi

# Check if the AWS CLI is configured
if [[ ! -d ~/.aws ]]; then
   echo "AWS CLI is not configured. Please configure it and try again"
   exit 1
fi

# list s3 buckets
# echo "Print list of S3 buckets"
# aws s3 ls

# describe buckets
echo "Print list of S3 buckets"
aws s3api list-buckets > resourceTracker

# list ec2 instances
echo "Print list of EC2 instance"
aws ec2 describe-instances | jq '.Reservations[].Instances[].InstanceId' >> resourceTracker

# list lambda
echo "Print list of lambda function"
aws lambda list-functions >> resourceTracker

# list IAM users
echo "Print list of IAM users"
aws iam list-users >> resourceTracker

# list VPC
echo "Print VPC"
aws ec2 describe-vpcs | jq '.Vpcs[].VpcId' >> resourceTracker

# ============================== end of script ==============================