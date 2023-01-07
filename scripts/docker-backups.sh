#!/bin/bash
# --------------------------------------------------
# Author: Rishi
#
# Description:
# This script is designed to create incremental backups of a folder.
# --------------------------------------------------

BACKUP_DIR="/root/HomeLab"

DESTINATION="/root/docker-backups"

BASE_NAME="docker-backup"

CURRENT_DATE=$(date +%Y-%m-%d_%H-%M-%S)

tar -czvf "$DESTINATION/$BASE_NAME-$CURRENT_DATE.tar.gz" --listed-incremental="$DESTINATION/snapshot.snar" "$BACKUP_DIR"

echo "Incremental backup of $BACKUP_DIR completed on $CURRENT_DATE"