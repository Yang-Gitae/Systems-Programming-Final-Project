#!/bin/bash

# Backup Verification Script
# This script checks if a backup file is valid and not corrupted.

# Define the base directory for backup and logs
BASE_DIR="$HOME/bu"

# Define the folder where backup files are stored
BACKUP_DIR="$BASE_DIR/backup"

# Define the log file to store verification messages
LOG_FILE="$BASE_DIR/log/verify.log"

# Get the backup file name from the first command-line argument
BACKUP_FILE=$1

# Check if the user provided a backup file name
if [[ -z "$BACKUP_FILE" ]]; then
    # If no file name is provided, show usage and exit
    echo "Usage: $0 <backup_file>"
    exit 1
fi

# Showing the message that it is starting
echo "Starting verification of $BACKUP_FILE at $(date)"
echo "Starting verification of $BACKUP_FILE at $(date)" >> "$LOG_FILE"

# Check if the backup file is encrypted (.gpg extension)
if [[ "$BACKUP_FILE" =~ \.gpg$ ]]; then
    # If the file is encrypted, decrypt it first
    echo "Encrypted backup detected. Decrypting $BACKUP_FILE..."
    gpg --output "$BACKUP_DIR/decrypted_backup.tar.gz" --decrypt "$BACKUP_DIR/$BACKUP_FILE"
    
    # Check if decryption was successful
    if [[ $? -ne 0 ]]; then
        echo "Decryption failed. Check your passphrase and try again." >> "$LOG_FILE"
        echo "Decryption failed."
        exit 1
    else
        echo "Decryption successful. Proceeding with verification." >> "$LOG_FILE"
        BACKUP_FILE="decrypted_backup.tar.gz"  # Update the backup file name to the decrypted file
    fi
fi

# Verify the backup file (now either decrypted or original)
echo "Verifying backup from $BACKUP_FILE..."
if tar -tzf "$BACKUP_DIR/$BACKUP_FILE" > /dev/null; then
    # If it is verified, show this message
    echo "Backup verified successfully: $BACKUP_FILE"
    echo "Backup verified successfully: $BACKUP_FILE" >> "$LOG_FILE"
else
    # Show error message if failed or have errors
    echo "Backup verification failed: $BACKUP_FILE. Check $LOG_FILE for details."
    echo "Backup verification failed: $BACKUP_FILE" >> "$LOG_FILE"
    exit 1
fi

# Completion Message
echo "Verification completed at $(date)"
echo "Verification completed at $(date)" >> "$LOG_FILE"

