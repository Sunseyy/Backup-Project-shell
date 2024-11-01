#!/bin/bash

# Check for the correct number of arguments
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <source_directory> <backup_directory> <remote_user> <remote_host>"
    exit 1
fi

# Define source and destination directories from command-line arguments
SOURCE="$1"  # This is the directory to back up
DESTINATION="$2"  # This is where the backup will be stored locally
REMOTE_USER="$3"  # Remote server user
REMOTE_HOST="$4"  # Remote server host

LOG_FILE="$DESTINATION/backup_log.txt"  # Log file for backup operations

# Get the current date for backup filenames
CURRENT_DATE=$(date +"%Y%m%d")
# Backup file names with date
FULL_BACKUP_FILE="$DESTINATION/full_backup_$CURRENT_DATE.tar"  # Full backup file name
# Incremental backup filename with date and timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
INCREMENTAL_BACKUP_FILE="$DESTINATION/incremental_backup_$CURRENT_DATE_$TIMESTAMP.tar"  # Incremental backup file name
SNAPSHOT_FILE="$DESTINATION/backup.snar"  # Snapshot file for incremental backups

# Function to create a full backup
create_full_backup() {
    echo "Creating full backup of $SOURCE..." | tee -a "$LOG_FILE"
    tar --create --file="$FULL_BACKUP_FILE" --listed-incremental="$SNAPSHOT_FILE" "$SOURCE" && \
    echo "Full backup created: $FULL_BACKUP_FILE" | tee -a "$LOG_FILE"
    echo "-----------------------------------" | tee -a "$LOG_FILE"
}

# Function to create an incremental backup
create_incremental_backup() {
    echo "Creating incremental backup of $SOURCE..." | tee -a "$LOG_FILE"
    echo "-----------------------------------" | tee -a "$LOG_FILE"
    tar --create --file="$INCREMENTAL_BACKUP_FILE" --listed-incremental="$SNAPSHOT_FILE" "$SOURCE" && \
    echo "Incremental backup created: $INCREMENTAL_BACKUP_FILE" | tee -a "$LOG_FILE"
    echo "-----------------------------------" | tee -a "$LOG_FILE"
}

# Function to copy backups to the remote server
copy_backup_to_remote() {
    echo "Copying backup to remote server..." | tee -a "$LOG_FILE"
    if scp "$FULL_BACKUP_FILE" "$REMOTE_USER@$REMOTE_HOST:$DESTINATION/" >> "$LOG_FILE" 2>&1; then
        echo "Full backup copied to remote server successfully." | tee -a "$LOG_FILE"
    else
        echo "Failed to copy full backup to remote server. Check the log for details." | tee -a "$LOG_FILE"
    fi

    if scp "$INCREMENTAL_BACKUP_FILE" "$REMOTE_USER@$REMOTE_HOST:$DESTINATION/" >> "$LOG_FILE" 2>&1; then
        echo "Incremental backup copied to remote server successfully." | tee -a "$LOG_FILE"
    else
        echo "Failed to copy incremental backup to remote server. Check the log for details." | tee -a "$LOG_FILE"
    fi
}

# Create log file if it does not exist
touch "$LOG_FILE"

# Main script logic
if [ ! -f "$SNAPSHOT_FILE" ]; then
    # If the snapshot file does not exist, create a full backup
    create_full_backup
else
    # If the snapshot file exists, create an incremental backup
    create_incremental_backup
fi

# Copy backups to the remote server
if [ -f "$FULL_BACKUP_FILE" ]; then
    copy_backup_to_remote
fi
if [ -f "$INCREMENTAL_BACKUP_FILE" ]; then
    copy_backup_to_remote
fi
