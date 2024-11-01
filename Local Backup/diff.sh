#!/bin/bash

# Check for the correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_directory> <backup_directory>"
    exit 1
fi

# Directories for backup from command-line arguments
SOURCE_DIR="$1"
BACKUP_DIR="$2"

# Log file for the backup (this will accumulate logs over time)
LOG_FILE="${BACKUP_DIR}/backup_log.txt"

# File to store the date of the last full backup
LAST_FULL_BACKUP_FILE="${BACKUP_DIR}/last_full_backup_date"

# Initialize log file if it does not exist
if [ ! -f "${LOG_FILE}" ]; then
    echo "Backup Log File Created: ${LOG_FILE}" > "${LOG_FILE}"
fi

{
    echo "==========================================="
    echo "Backup started at: $(date +"%Y-%m-%d %H:%M:%S")"
    
    # Determine if a full backup has been made
    if [ -f "${LAST_FULL_BACKUP_FILE}" ]; then
        LAST_FULL_BACKUP_DATE=$(cat "${LAST_FULL_BACKUP_FILE}")
        BACKUP_SUFFIX="_diff"
        echo "Performing differential backup (changes since $LAST_FULL_BACKUP_DATE)..."
    else
        # If no previous full backup, perform a full backup
        LAST_FULL_BACKUP_DATE="1970-01-01 00:00:00"
        BACKUP_SUFFIX="_full"
        echo "No previous backup found. Performing full backup..."
        date +"%Y-%m-%d %H:%M:%S" > "${LAST_FULL_BACKUP_FILE}"
    fi

    # Perform the backup using tar and log the output
    echo "Creating backup file..."
    BACKUP_FILE="${BACKUP_DIR}/backup_$(date +"%Y-%m-%d_%H-%M-%S")${BACKUP_SUFFIX}.tar.gz"
    
    # Create a differential backup with tar
    if tar --create --gzip --file="$BACKUP_FILE" --newer-mtime="$LAST_FULL_BACKUP_DATE" "$SOURCE_DIR" > "${LOG_FILE}" 2>&1; then
        echo "Backup successful: $BACKUP_FILE"
        
        # Update the last full backup date if it's a full backup
        if [[ "$BACKUP_SUFFIX" == "_full" ]]; then
            date +"%Y-%m-%d %H:%M:%S" > "${LAST_FULL_BACKUP_FILE}"
        fi

        # List the files included in the backup and append to the log
        echo "Files included in the backup:" >> "${LOG_FILE}"
        tar -tzf "$BACKUP_FILE" >> "${LOG_FILE}"
    else
        echo "Backup failed. Check the log file for details: ${LOG_FILE}"
    fi

    echo "Backup finished at: $(date +"%Y-%m-%d %H:%M:%S")"
    echo "==========================================="
} >> "${LOG_FILE}" 2>&1  # Append all output to the log file
