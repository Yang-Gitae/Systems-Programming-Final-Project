#!/bin/bash

# Define the folder to back up and where the backup will be saved
BACKUP_SOURCE="$HOME/bu/data"
BACKUP_DEST="$HOME/bu/backup"

# Get the current date and time for the backup filename
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Name of the backup file
BACKUP_NAME="full_backup_$DATE.tar.gz"
ENCRYPTED_NAME="$BACKUP_NAME.gpg"

# Start the backup process
echo "Starting full backup of $BACKUP_SOURCE"

# Create a compressed backup of the source folder
tar -czf "$BACKUP_DEST/$BACKUP_NAME" -C "$BACKUP_SOURCE" .

# Check if the backup command worked
if [ $? -eq 0 ]; then
    echo "Backup file created: $BACKUP_DEST/$BACKUP_NAME"
else
    echo "Error during full backup" >&2
    exit 1
fi

# Retention policy: Delete full backups older than 1 month
echo "Checking for full backups older than 1 month..." | tee -a "$LOG_FILE"
find "$BACKUP_DEST" -name "full_backup_*.tar.gz" -mtime +30 -exec rm {} \; -print | tee -a "$LOG_FILE"
if [ $? -eq 0 ]; then
    echo "Retention policy applied: Old full backups removed (if any)." | tee -a "$LOG_FILE"
else
    echo "ERROR: Failed to apply retention policy for full backups." | tee -a "$LOG_FILE"
fi

# Encrypt the backup file
echo "Encrypting the backup file for additional protection..."
gpg --symmetric --cipher-algo AES256 --output "$BACKUP_DEST/$ENCRYPTED_NAME" "$BACKUP_DEST/$BACKUP_NAME"

# Check if the encryption command worked
if [ $? -eq 0 ]; then
    # If successful, remove the unencrypted tar.gz file and show a success message
    rm "$BACKUP_DEST/$BACKUP_NAME"
    echo "Backup file successfully encrypted: $BACKUP_DEST/$ENCRYPTED_NAME"
else
    # If there was an error, show an error message and exit the script
    echo "Error during encryption" >&2
    exit 1
fi

