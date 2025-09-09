#!/bin/bash

# ========================== Shell script to jenkins logs to S3 bucket ===========================
#
# Author: Vedansh kumar
# Version: v0.0.1
# Date: 2024-06-10
# Description: This script uploads Jenkins logs to an S3 bucket for backup and analysis.
#
set -euo pipefail

# variables
JENKINS_HOME="/var/lib/jenkins"
S3_BUCKET="s3://jenkins-cost-optimizations-project"
DATE=$(date +%Y-%m-%d)

# check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it to proceed"
    exit 1
fi

# Iterate through all job directories
for job_dir in "$JENKINS_HOME/jobs/"*/; do
    job_name=$(basename "$job_dir")
    echo "your jenkins job name : $job_name"

    # Iterate through build directories for the job
    for build_dir in "$job_dir/builds/"*/; do
        # Get build number and log file path
        build_number=$(basename "$build_dir")
        log_file="$build_dir/log"

        # Check if log file exists and was created today"
        if [ -f "$log_file" ] && [ "$(date -r "$log_file" +%Y-%m-%d)" == "$DATE" ]; then
            # Upload log file to S3 bucket with the build number as the filename
            aws s3 cp "$log_file" "$S3_BUCKET/$job_name-$build_number.log" --only-show-errors

            if [ $? -eq 0 ]; then
                echo "Uploaded: $job_name/$build_number to $S3_BUCKET/$job_name-$build_number.log"
            else
                echo "Failed to Upload: $job_name/$build_number"
            fi
        fi
    done
done




