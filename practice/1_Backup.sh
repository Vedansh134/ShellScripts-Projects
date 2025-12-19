#!/bin/bash

# ----------------------------
# Do practice of shell script
# ----------------------------

# for testing
set -eou pipefail

# create variables for path
SOURCE_DIR = "/home/user1/data"
DESTINATION_DIR = "/home/backup"

# Set timeline variable
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: Source directory does not exist $SOURCE_DIR"
    exit 1
fi

# creates destination folder if not exist
if [[ ! -d "$DESTINATION_DIR" ]]; then
    echo "Destination folder not exist, create folder"
    mkdir -p "$DESTINATION_DIR"
fi

# define the backup file name
BACKUP_FILE="${TIMESTAMP}_tar.gz"

# Now create backup
tar -cvzf ${DESTINATION_DIR}/${BACKUP_FILE} ${SOURCE_DIR}

# Check backup create or not
if [[ $? -eq 0 ]];then
    echo "Backup copleted : ${DESTINATION_DIR}/${BACKUP_FILE}"
else
    echo "Backup failed!"
    exit 1
fi

# --------------------------------
