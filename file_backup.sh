#!/bin/bash

############################################################################
# linux file backup shell scripting
# version: 1.0
# date: 06-10-2025
# author: vedansh kumar
# description: In this shell script it create backup of file
#############################################################################

# for testing (set -xeou pipefail)
set +euo pipefail   # exit on error, unset var error, and fail on pipe errors
# set -x            # uncomment for debugging

# define variables
SUDO="sudo"

# Define source and destination directories
SOURCE_DIR="/home/ubuntu/data"
BACKUP_DIR="/home/backup"

# Create a timestamp for the backup file name
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Check source exists and is a directory
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error : Source directory does not exist $SOURCE_DIR"
    exit 2
fi

# Define the backup file name
BACKUP_FILE="backup_${TIMESTAMP}_tar.gz"

# Create the compressed tar archive
tar -czvf ${BACKUP_DIR}/${BACKUP_FILE} ${SOURCE_DIR}

echo "Backup completed: ${BACKUP_DIR}/${BACKUP_FILE}"

# ========================================= end of script =======================================