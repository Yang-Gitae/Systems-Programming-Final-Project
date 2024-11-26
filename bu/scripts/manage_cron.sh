.#!/bin/bash

# Variables
CRON_FILE="/tmp/current_cron"
FULL_BACKUP_JOB="0 2 * * 0 /home/$(whoami)/bu/scripts/full.sh >> /home/$(whoami)/bu/log/full_backup.log 2>&1"
INCREMENTAL_BACKUP_JOB="0 2 * * * /home/$(whoami)/bu/scripts/incre.sh >> /home/$(whoami)/bu/log/incremental_backup.log 2>&1"

# Function to activate cron jobs
activate_cron() {
    echo "Activating backup automation..."
    
    # Backup existing cron jobs
    crontab -l > "$CRON_FILE" 2>/dev/null
    
    # Add the backup jobs
    {
        echo "$FULL_BACKUP_JOB"
        echo "$INCREMENTAL_BACKUP_JOB"
    } >> "$CRON_FILE"
    
    # Install the updated cron jobs
    crontab "$CRON_FILE"
    echo "Backup automation activated."
}

# Function to deactivate cron jobs
deactivate_cron() {
    echo "Deactivating backup automation..."
    
    # Backup existing cron jobs
    crontab -l > "$CRON_FILE" 2>/dev/null
    
    # Remove or comment out the backup jobs
    sed -i.bak "/$(echo "$FULL_BACKUP_JOB" | sed 's/[]\/$*.^|[]/\\&/g')/d" "$CRON_FILE"
    sed -i.bak "/$(echo "$INCREMENTAL_BACKUP_JOB" | sed 's/[]\/$*.^|[]/\\&/g')/d" "$CRON_FILE"
    
    # Install the updated cron jobs
    crontab "$CRON_FILE"
    echo "Backup automation deactivated."
}

# Main Menu
case $1 in
    activate)
        activate_cron
        ;;
    deactivate)
        deactivate_cron
        ;;
    *)
        echo "Usage: $0 {activate|deactivate}"
        exit 1
        ;;
esac
