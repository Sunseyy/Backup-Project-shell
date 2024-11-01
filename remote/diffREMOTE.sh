#!/bin/bash

# Check for the correct number of arguments
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <source_directory> <backup_directory> <remote_user> <remote_host>"
    exit 1
fi

# Directories and remote host from command-line arguments
SOURCE_DIR="$1"
BACKUP_DIR="$2"
REMOTE_USER="$3"
REMOTE_HOST="$4"

# Current date and time for the backup
CURRENT_DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Log file for the backup
LOG_FILE="${BACKUP_DIR}/backup_log_${CURRENT_DATE}.log"

# File to store the date of the last full backup
LAST_FULL_BACKUP_FILE="${BACKUP_DIR}/last_full_backup_date"

# Determine if a full backup has been made
if [ -f "${LAST_FULL_BACKUP_FILE}" ]; then
    LAST_FULL_BACKUP_DATE=$(cat "${LAST_FULL_BACKUP_FILE}")
    BACKUP_SUFFIX="_diff"
else
    # If no previous full backup, perform a full backup
    LAST_FULL_BACKUP_DATE="1970-01-01 00:00:00"
    BACKUP_SUFFIX="_full"
    date +"%Y-%m-%d %H:%M:%S" > "${LAST_FULL_BACKUP_FILE}"
fi

# Perform the backup using tar
LOCAL_BACKUP_FILE="${BACKUP_DIR}/backup_${CURRENT_DATE}${BACKUP_SUFFIX}.tar.gz"
tar --create --gzip --file="${LOCAL_BACKUP_FILE}" --newer-mtime="${LAST_FULL_BACKUP_DATE}" "${SOURCE_DIR}" > "${LOG_FILE}" 2>&1

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup successful: ${LOCAL_BACKUP_FILE}" | tee -a "${LOG_FILE}"

    # Copy the backup to the remote server
    scp "${LOCAL_BACKUP_FILE}" "${REMOTE_USER}@${REMOTE_HOST}:${BACKUP_DIR}/" >> "${LOG_FILE}" 2>&1

    if [ $? -eq 0 ]; then
        echo "Backup copied to remote server successfully." | tee -a "${LOG_FILE}"
    else
        echo "Failed to copy backup to remote server. Check the log for details." | tee -a "${LOG_FILE}"
    fi
else
    echo "Backup failed. Check the log file for details: ${LOG_FILE}" | tee -a "${LOG_FILE}"
fi
