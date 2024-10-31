#!/bin/bash

# Directories for backup
SOURCE_DIR="/home/sunsey/source"
BACKUP_DIR="/home/sunsey/diff_backup"

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
tar --create --gzip --file="${BACKUP_DIR}/backup_${CURRENT_DATE}${BACKUP_SUFFIX}.tar.gz" --newer-mtime="${LAST_FULL_BACKUP_DATE}" "${SOURCE_DIR}" > "${LOG_FILE}" 2>&1

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup successful: ${BACKUP_DIR}/backup_${CURRENT_DATE}${BACKUP_SUFFIX}.tar.gz" | tee -a "${LOG_FILE}"
else
    echo "Backup failed. Check the log file for details: ${LOG_FILE}" | tee -a "${LOG_FILE}"
fi
