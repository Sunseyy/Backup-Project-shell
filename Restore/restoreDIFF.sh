
#!/bin/bash

# Directories for backup
BACKUP_DIR="/home/sunsey/diff_backup"
RESTORE_DIR="/home/sunsey/restore"

# Create the restore directory if it does not exist
mkdir -p "${RESTORE_DIR}"

# Find the latest full backup
FULL_BACKUP=$(ls "${BACKUP_DIR}/backup_"*_full.tar.gz 2>/dev/null | sort | tail -n 1)

# Find the latest differential backup
DIFF_BACKUP=$(ls "${BACKUP_DIR}/backup_"*_diff.tar.gz 2>/dev/null | sort | tail -n 1)

# Check if the full backup exists
if [[ -z "$FULL_BACKUP" ]]; then
    echo "No full backup found. Cannot restore."
    exit 1
fi

# Restore the full backup
echo "Restoring full backup: ${FULL_BACKUP}..."
tar --extract --gzip --file="${FULL_BACKUP}" --directory="${RESTORE_DIR}"

# Check if the differential backup exists
if [[ -n "$DIFF_BACKUP" ]]; then
    # Restore the latest differential backup
    echo "Restoring differential backup: ${DIFF_BACKUP}..."
    tar --extract --gzip --file="${DIFF_BACKUP}" --directory="${RESTORE_DIR}"
else
    echo "No differential backup found. Only full backup restored."
fi

echo "Restore completed successfully."
