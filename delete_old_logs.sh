#!/bin/bash

# ======================= delete_old_logs.sh =============================
# version: 1.0
# Author: Vedansh kumar
# DateL 16-10-2025
# Description: This script deletes log files older than a specified number of days from a given directory.
# Usage: ./delete_old_logs.sh /path/to/logs days
# Example: ./delete_old_logs.sh /var/log 30
# =========================================================================

# testing (change to set -xeou pipefail for testing)
set +xeou pipefail

# define variables
SUDO='sudo'

# example usuage for not knowning person
echo "./delete_old_logs.sh /var/log 30"

# define log file path
read -p "Enter your log file location : " log_file

# Define the number of days after which log files should be deleted
read -p "Enter no. of days after which logs files delete : " DAYS_OLD

# find and delete the old files
delete_old_logfile(){
    echo "delete old log file"
    if ! log_file; then
        echo "Your enter location for log file is not exist"
    else
        find log_file -type f -name *.log $DAYS_OLD -exec rm {} \;
        echo "old file delete successfully"
    fi
}

delete_old_logfile