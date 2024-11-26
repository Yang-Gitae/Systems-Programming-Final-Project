BACKUP AND DISASTER RECOVERY SYSTEM
===================================

OVERVIEW
--------
This project automates the backup and disaster recovery process using 
Bash scripts and cron jobs. It includes:

- Full backups (weekly)
- Incremental backups (daily)
- Data restoration
- Backup verification
- Automated scheduling with cron

This system ensures reliable and efficient backups to safeguard critical data.

PROJECT STRUCTURE
-----------------
The project resides under the directory `~/bu` with the following structure:

~/bu
├── backup       # Stores all backup files (full and incremental)
├── data         # Source directory for data to be backed up
├── log          # Logs for backup, restoration, and verification processes
├── restore      # Directory where backups are restored
├── scripts      # Bash scripts for managing the backup process
│   ├── full.sh          # Creates a full backup
│   ├── incre.sh         # Creates an incremental backup
│   ├── restore.sh       # Restores data from backups
│   ├── verif.sh         # Verifies the integrity of backups
│   ├── manage_cron.sh   # Activates or deactivates backup automation

SETUP INSTRUCTIONS
------------------

1. Create the Project Directory
   --------------------------------
   Use the following command to create the project directory and structure:
   $ mkdir -p ~/bu/{backup,data,log,restore,scripts}

2. Place the Scripts
   ------------------
   Copy the provided scripts into the `~/bu/scripts/` directory.

3. Make Scripts Executable
   ------------------------
   Run the following commands:
   $ chmod +x ~/bu/scripts/full.sh
   $ chmod +x ~/bu/scripts/incre.sh
   $ chmod +x ~/bu/scripts/restore.sh
   $ chmod +x ~/bu/scripts/verif.sh
   $ chmod +x ~/bu/scripts/manage_cron.sh

4. Initialize the Data Directory
   -----------------------------
   Place the files or directories you want to back up into `~/bu/data`.

5. Test the Scripts
   -----------------
   Run each script manually to confirm it works:
   
   Full Backup:
   $ ~/bu/scripts/full.sh

   Incremental Backup:
   $ ~/bu/scripts/incre.sh

   Restore Backup:
   $ ~/bu/scripts/restore.sh <backup_file_name>

   Verify Backup:
   $ ~/bu/scripts/verif.sh <backup_file_name>

   Logs for all scripts are stored in the `~/bu/log/` directory.

LOGS
----
Logs are stored in the `~/bu/log/` directory:
- full_backup.log: Logs for full backups
- incremental_backup.log: Logs for incremental backups
- restore.log: Logs for restoration processes
- verify.log: Logs for verification processes

You can view the logs using the following command:
$ tail -n 10 ~/bu/log/<log_file>

TROUBLESHOOTING
---------------
1. Ensure Scripts Are Executable:
   $ chmod +x ~/bu/scripts/*.sh

2. Verify Cron Service Is Running:
   $ systemctl status cron

   If it is not running, start it:
   $ sudo systemctl start cron

3. Check Logs for Errors:
   $ tail -n 20 ~/bu/log/full_backup.log
   $ tail -n 20 ~/bu/log/incremental_backup.log

4. Manually Test the Scripts:
   $ ~/bu/scripts/full.sh
   $ ~/bu/scripts/incre.sh


CUSTOMIZING THE SCHEDULE
------------------------
To modify the backup schedule, edit the cron jobs:
$ crontab -e

For example:
- Full backup every week on Sunday at 2 AM:
  0 2 * * 0 /home/<username>/bu/scripts/full.sh >> /home/<username>/bu/log/full_backup.log 2>&1

- Incremental backup every day at 2 AM:
  0 2 * * * /home/<username>/bu/scripts/incre.sh >> /home/<username>/bu/log/incremental_backup.log 2>&1

ACKNOWLEDGMENTS
---------------
This project was designed to automate backups and provide a reliable disaster 
recovery system using Bash scripting and cron automation.
