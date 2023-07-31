#!/bin/sh

# Run restic backup
restic backup /data

# If restic backup succeeds, then run wget command
if [ $? -eq 0 ]; then
    wget $HEALTHCHECKS_URL
else
    echo "Restic backup failed."
fi
