#!/bin/bash

# Restore Script
# This script restores data from a backup file, with decryption support.

# Define the base directory for backup and restore operations
BASE_DIR="$HOME/bu"

# Define the folder where backup files are stored
BACKUP_DIR="$BASE_DIR/backup"

# Define the folder where the backup will be restored
DATA_DIR="$BASE_DIR/restore"

# Define the log file to store restore messages
LOG_FILE="$BASE_DIR/log/restore.log"

# Get the backup file name from the first command-line argument
BACKUP_FILE=$1

# Check if the user provided a backup file name
if [[ -z "$BACKUP_FILE" ]]; then
    # If no file name is provided, prompt usage message
    echo "Usage: $0 <backup_file>"
    exit 1
fi

# Start of the restore process with log files 
echo "Starting restore at $(date)"
echo "Starting restore at $(date)" >> "$LOG_FILE"

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
        echo "Decryption successful. Proceeding with restoration." >> "$LOG_FILE"
        BACKUP_FILE="decrypted_backup.tar.gz"  # Update the backup file name to the decrypted file
    fi
fi

# Restoring the backup file (now either decrypted or original)
echo "Restoring backup from $BACKUP_FILE into $DATA_DIR..."
if tar -xzf "$BACKUP_DIR/$BACKUP_FILE" -C "$DATA_DIR"; then
    # If successful, show and log a success message
    echo "Restore successful: $BACKUP_FILE"
    echo "Restore successful: $BACKUP_FILE" >> "$LOG_FILE"
else
    # If it fails, show and log an error message
    echo "Restore failed. Check $LOG_FILE for details."
    echo "Restore failed" >> "$LOG_FILE"
    exit 1
fi

# Show the message of completion and have log file
echo "Restore completed at $(date)"
echo "Restore completed at $(date)" >> "$LOG_FILE"

