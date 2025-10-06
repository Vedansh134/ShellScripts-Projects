#!/bin/bash

################################################################################
# create_ec2_instance.sh
# version: 1.0
# author: Vedansh kumar
# date: 04-10-2025
# description: This script creates an EC2 instance using AWS CLI.
################################################################################

# testing (change to set -xeou pipefail for testing)
# safe defaults; add -x while debugging: set -euo pipefail; set -x
set +euo pipefail

# define variables
SUDO='sudo'
ami_id="ami-0f9708d1cd2cfee41"
instance_type="t2.micro"
key_name="mumbai"
subnet_id="subnet-00900b662e15c67d1"
security_group_ids="sg-0e748f832ddcd7f71"
instance_name="testing"

# Update ubuntu
echo " 🛠️ Updating Ubuntu packages..."
$SUDO apt-get update -y
echo ""

# check AWS CLI is installed or not
check_awscli() {
    if command -v aws >/dev/null 2>&1; then
        echo "✅ AWS CLI is already installed: $(aws --version 2>&1)"
        return 0
    else
        echo "AWS CLI is not installed, install AWS CLI ..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        $SUDO apt install unzip -y
        unzip awscliv2.zip
        $SUDO ./aws/install
        echo "✅ AWS CLI installed: $(aws --version 2>&1)"
    fi
}

# check if AWS CLI is configured or not
check_awscli_configure() {
    if [[ ! -d ~/.aws ]]; then
        echo "AWS CLI is not configured. Please configure it and try again"
        echo "Run 'aws configure' or set AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY and optional AWS_REGION."
        exit 1
    fi
}

# create ec2 instance
create_ec2_instance() {
    echo "Creating EC2 instance..."

    instance_id=$(
        aws ec2 run-instances \
            --image-id "$ami_id" \
            --instance-type "$instance_type" \
            --key-name "$key_name" \
            --subnet-id "$subnet_id" \
            --security-group-ids "$security_group_ids" \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
            --count 1 \
            --query 'Instances[0].InstanceId' \
            --output text
    )

    if [[ -z $instance_id ]]; then
        echo "Failed to create EC2 instance."
        exit 1
    fi

    echo "Instance $instance_id created successfully."

    # Wait for the instance to be in running state
}

# main function to call other functions
main() {
    echo "Starting EC2 instance creation process..."

    check_awscli
    check_awscli_configure
    create_ec2_instance

    echo "✅ EC2 instance ($instance_id) successfully created and running."
}

# invoke main function
main

# ================================= end of script =================================