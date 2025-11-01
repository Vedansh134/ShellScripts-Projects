#!/bin/bash

# ========================= AWS resource shell script =======================
# Description: This script will be list of all AWS resources list
# Author: Vedansh kumar
# Date: 2024-06-10
# Version: v0.0.1
# Description: Use shell script to create aws s3 bucket
# Usage: ./create-s3-Bucket.sh <bucket-name> <region>
# Example: ./create-s3-Bucket.sh my-unique-bucket-name ap-south-1
# ============================================================================

# for testing use set -exuo pipefail
set +exuo pipefail

# Check if the required no. of arguements are passed
if [[ $# -ne 2 ]];then
    echo "Usage: $0 <bucket-name> <region>"
    exit 1
fi

# Check if the AWS CLI is installed or not
if ! command -v aws &> /dev/null;then
    echo "AWS CLI is not installed. Please Install & configure it and try again"
    exit 1
fi

# Create the S3 bucket
BUCKET_NAME="my-bucket-$RANDOM"
aws s3 mb s3://$1 --region $2

# Check if the bucket is created successfully
if [[ $? -eq 0]];then
    echo "S3 bucket '$1' created successfully in region $2"
else
    echo "Failed to create S3 bucket '$1' in region $2"
    exit 1
fi

# ================================= End of Script ==============================