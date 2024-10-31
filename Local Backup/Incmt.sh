#!/bin/bash

# Define source and destination directories
SOURCE="/home/sunsey/source"  # This is the directory to back up
DESTINATION="/home/sunsey/Backup"  # This is where the backup will be stored
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
    echo"-----------------------------------" | tee -a "$LOG_FILE"
}

# Function to create an incremental backup
create_incremental_backup() {
    echo "Creating incremental backup of $SOURCE..." | tee -a "$LOG_FILE"
    echo"-----------------------------------" | tee -a "$LOG_FILE"
    tar --create --file="$INCREMENTAL_BACKUP_FILE" --listed-incremental="$SNAPSHOT_FILE" "$SOURCE" && \
    echo "Incremental backup created: $INCREMENTAL_BACKUP_FILE" | tee -a "$LOG_FILE"
    echo"-----------------------------------" | tee -a "$LOG_FILE"
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
