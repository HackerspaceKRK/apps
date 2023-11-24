#!/bin/sh

# Run restic backup
restic backup /data --exclude=/data/building-automation_frigate_recordings/
restic forget --keep-daily 3 --keep-weekly 2 --keep-monthly 1 --keep-yearly 1
restic prune

# If restic backup succeeds, then run wget command
if [ $? -eq 0 ]; then
    wget $HEALTHCHECKS_URL
else
    echo "Restic backup failed."
fi
