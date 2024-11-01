#!/bin/bash

# Define destination directory for restoration
DESTINATION="/home/sunsey/restore" # Change this to your desired restore path
BACKUP_DIR="/home/sunsey/Backup"    # Directory where backups are stored

# Create destination directory if it doesn't exist
mkdir -p "$DESTINATION"

# Function to restore from a full backup
restore_full_backup() {
    local full_backup_file="$1"
    echo "Restoring from full backup: $full_backup_file..."
    tar --extract --file="$full_backup_file" -C "$DESTINATION" && \
    echo "Restoration complete from full backup: $full_backup_file"
}

# Function to restore from an incremental backup
restore_incremental_backup() {
    local incremental_backup_file="$1"
    echo "Restoring from incremental backup: $incremental_backup_file..."
    tar --extract --file="$incremental_backup_file" -C "$DESTINATION" && \
    echo "Restoration complete from incremental backup: $incremental_backup_file"
}

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory '$BACKUP_DIR' does not exist."
    exit 1
fi

# List all backup files
echo "Available backup files in $BACKUP_DIR:"
backup_files=("$BACKUP_DIR/"*)

# Restore each backup file
for backup_file in "${backup_files[@]}"; do
    if [[ -f "$backup_file" ]]; then
        if [[ "$backup_file" == *full_backup* ]]; then
            restore_full_backup "$backup_file"
        elif [[ "$backup_file" == *incremental_backup* ]]; then
            restore_incremental_backup "$backup_file"
        else
            echo "Skipping unknown file: $backup_file"
        fi
    fi
done

echo "All available backups have been processed."
