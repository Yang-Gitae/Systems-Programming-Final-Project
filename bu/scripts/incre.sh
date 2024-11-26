#!/bin/bash

# Variables
BASE_DIR="$HOME/bu"
BACKUP_SOURCE="$BASE_DIR/data"
BACKUP_DEST="$BASE_DIR/backup"
SNAPSHOT_DIR="$BASE_DIR/snapshot"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="incremental_backup_$DATE.tar.gz"
ENCRYPTED_NAME="$BACKUP_NAME.gpg"
LOG_FILE="$BASE_DIR/log/incremental_backup.log"

# Start logging
echo "===================================================" | tee -a "$LOG_FILE"
echo "Starting incremental backup at $(date)" | tee -a "$LOG_FILE"

# Ensure source directory exists
if [ ! -d "$BACKUP_SOURCE" ]; then
    echo "ERROR: Source directory $BACKUP_SOURCE does not exist!" | tee -a "$LOG_FILE"
    exit 1
fi

# Ensure destination directory exists
if [ ! -d "$BACKUP_DEST" ]; then
    echo "Backup destination $BACKUP_DEST does not exist. Creating it..." | tee -a "$LOG_FILE"
    mkdir -p "$BACKUP_DEST"
fi

# Ensure snapshot directory exists
if [ ! -d "$SNAPSHOT_DIR" ]; then
    echo "Snapshot directory $SNAPSHOT_DIR does not exist. Initializing it..." | tee -a "$LOG_FILE"
    mkdir -p "$SNAPSHOT_DIR"
    cp -r "$BACKUP_SOURCE"/* "$SNAPSHOT_DIR/"
    echo "Snapshot initialized with the current state of the source directory." | tee -a "$LOG_FILE"
fi

# Compare current source with snapshot
echo "Checking for changes between source and snapshot..." | tee -a "$LOG_FILE"
DIFF=$(diff -rq "$BACKUP_SOURCE" "$SNAPSHOT_DIR")

if [ -z "$DIFF" ]; then
    echo "No changes detected. Incremental backup not required." | tee -a "$LOG_FILE"
    exit 0
fi

# Changes detected: Create incremental backup
echo "Changes detected. Creating incremental backup..." | tee -a "$LOG_FILE"
tar -czf "$BACKUP_DEST/$BACKUP_NAME" -C "$BACKUP_SOURCE" . 2>>"$LOG_FILE"
if [ $? -eq 0 ]; then
    echo "Incremental backup completed successfully: $BACKUP_DEST/$BACKUP_NAME" | tee -a "$LOG_FILE"
else
    echo "ERROR: Incremental backup failed. See log for details." | tee -a "$LOG_FILE"
    exit 1
fi

# Retention policy implemented to delete incremental backups older than 7 days
echo "Checking for incremental backups older than 7 days..." | tee -a "$LOG_FILE"
find "$BACKUP_DEST" -name "incremental_backup_*.tar.gz" -mtime +7 -exec rm {} \; -print | tee -a "$LOG_FILE"
if [ $? -eq 0 ]; then
    echo "Retention policy applied: Old incremental backups removed (if any)." | tee -a "$LOG_FILE"
else
    echo "ERROR: Failed to apply retention policy for incremental backups." | tee -a "$LOG_FILE"
fi

# Encrypt the incremental backup
echo "Encrypting the incremental backup for additional protection..." | tee -a "$LOG_FILE"
gpg --symmetric --cipher-algo AES256 --output "$BACKUP_DEST/$ENCRYPTED_NAME" "$BACKUP_DEST/$BACKUP_NAME" 2>>"$LOG_FILE"
if [ $? -eq 0 ]; then
    rm "$BACKUP_DEST/$BACKUP_NAME"  # Remove the unencrypted backup
    echo "Incremental backup encrypted successfully: $BACKUP_DEST/$ENCRYPTED_NAME" | tee -a "$LOG_FILE"
else
    echo "ERROR: Encryption failed. See log for details." | tee -a "$LOG_FILE"
    exit 1
fi

# Update snapshot directory
echo "Updating snapshot directory with the latest state of the source directory..." | tee -a "$LOG_FILE"
rsync -a --delete "$BACKUP_SOURCE"/ "$SNAPSHOT_DIR"/ 2>>"$LOG_FILE"
if [ $? -eq 0 ]; then
    echo "Snapshot updated successfully." | tee -a "$LOG_FILE"
else
    echo "ERROR: Failed to update snapshot. See log for details." | tee -a "$LOG_FILE"
    exit 1
fi

# Finish
echo "Incremental backup process completed at $(date)" | tee -a "$LOG_FILE"
echo "===================================================" | tee -a "$LOG_FILE"
exit 0

