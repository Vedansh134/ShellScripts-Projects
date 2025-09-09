#!/bin/bash

############################################################################
# ========================= AWS resource shell script =======================

# Use shell script to access active aws resources
# firstly identify your org main aws services like ec2,iam,vpc,s3,rds,eks etc
# automate via cron job and alert by email to management team also

# This script will be list of all AWS resources list
# Author: Vedansh
# Version: v0.0.1
#
# Folllowing are the supported AWS Services by the script
# 1. EC2
# 2. EBS
# 3. ELB
# 4. AutoScaling
# 5. S3
# 6. VPC
# 7. IAM
# 8. RDS
# 9. DynamoDB
# 10. Lambda
# 11. CloudFront
# 12. CloudWatch
# 13. CloudFormation
# 14. Route53
# 15. SNS
# 16. SQS
# 17. ECR
# 18. ECS
# 19. EKS
# 20. KMS
# 21. Secrets Manager
#
# How to use this shell script
# Usage : ./aws_resource_list-sh <region> <service>
# Example :  ./aws-resource_list.sh ap-south-1 EC2
#
#######################################################################

# for testing
set -euo pipefail

# Check if the required no. of arguements are passed
if [[ $# -ne 2 ]]; then
   echo "Usuage: $0 <aws_region> <aws_service_name>"
   exit 1
fi

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

# Execute the AWS CLI Command based on the services name
case $2 in
   EC2)
    aws ec2 describe-instances --region $1
    ;;
   EBS)
    aws ec2 describe-volumes --region $1
    ;;
   ELB)
    aws elbv2 describe-load-balancers --region $1
    ;;
   AutoScaling)
    aws autoscaling describe-auto-scaling-groups --region $1
    ;;
   S3)
    aws s3api list-buckets --region $1
    ;;
   VPC)
    aws ec2 describe-vpcs --region $1
    ;;
   IAM)
    aws iam list-users --region $1
    ;;
   RDS)
    aws rds describe-db-instances --region $1
    ;;
   DyanmoDB)
    aws dynamodb list-tables --region $1
    ;;
   Lambda)
    aws lambda list-functions --region $1
    ;;
   CloudFront)
    aws cloudfront list-distributions --region $1
    ;;
   CloudWatch)
    aws cloudwatch list-metrics --region $1
    ;;
   CloudFormation)
    aws cloudformation list-stacks --region $1
    ;;
   Route53)
    aws route53 list-hosted-zones --region $1
    ;;
   SNS)
    aws sns list-topics --region $1
    ;;
   SQS)
    aws sqs list-queues --region $1
    ;;
   ECR)
    aws ecr describe-repositories --region $1
    ;;
   ECS)
    aws ecs list-clusters --region $1
    ;;
   EKS)
    aws eks list-clusters --region $1
    ;;
   KMS)
    aws kms list-keys --region $1
    ;;
   SecretsManager)
    aws secretsmanager list-secrets --region $1
    ;;
   *)
    echo "Invalid Service name. Please provide a valid service name."
    exit 1
    ;;
esac

#
# for permission
# chmod 711 aws_resource_list.sh
# 711 = rwx--x--x
#
# root = rwx (read, write, execute)
# group = --x (execute)
# others = --x (execute)
#
# ========================= End of the script ==============================
