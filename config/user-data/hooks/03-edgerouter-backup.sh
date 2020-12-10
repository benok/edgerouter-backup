#!/bin/bash
source /config/user-data/edgerouter-backup.conf

# This script runs during the commit

# Pull commit info
COMMIT_VIA=${COMMIT_VIA:-other}
COMMIT_CMT=${COMMIT_COMMENT:-$DEFAULT_COMMIT_MESSAGE}

# If no comment, replace with default
if [ "$COMMIT_CMT" == "commit" ];
then
    COMMIT_CMT=$DEFAULT_COMMIT_MESSAGE
fi

# Check if rollback
if [ $# -eq 1 ] && [ $1 = "rollback" ];
then
    COMMIT_VIA="rollback/reboot"
fi

TIME=$(date +%Y-%m-%d" "%H:%M:%S)
USER=$(whoami)

GIT_COMMIT_MSG="$COMMIT_CMT | by $USER | via $COMMIT_VIA | $TIME"

# Remove temporary files
#echo "edgerouter-backup: Removing temporary files"
sudo rm /tmp/edgerouter-backup-$FNAME_CONFIG  &> /dev/null
sudo rm /tmp/edgerouter-backup-$FNAME_CLI  &> /dev/null
sudo rm /tmp/edgerouter-backup-$FNAME_BACKUP.tar.gz  &> /dev/null


# Generate temporary config files
sudo cli-shell-api showConfig --show-active-only --show-ignore-edit --show-show-defaults > /tmp/edgerouter-backup-$FNAME_CONFIG
sudo cli-shell-api showConfig --show-commands --show-active-only --show-ignore-edit --show-show-defaults > /tmp/edgerouter-backup-$FNAME_CLI
sudo tar -czvf /tmp/edgerouter-backup-$FNAME_BACKUP.tar.gz /config

# Push config files
echo "edgerouter-backup: Copying backup files to $SSH_USER@$SSH_HOST:$REPO_PATH"
sudo scp -q -i $SSH_KEYFILE -P $SSH_PORT -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /tmp/edgerouter-backup-$FNAME_CONFIG $SSH_USER@$SSH_HOST:$REPO_PATH/$FNAME_CONFIG > /dev/null
sudo scp -q -i $SSH_KEYFILE -P $SSH_PORT -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /tmp/edgerouter-backup-$FNAME_CLI $SSH_USER@$SSH_HOST:$REPO_PATH/$FNAME_CLI > /dev/null
sudo scp -q -i $SSH_KEYFILE -P $SSH_PORT -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /tmp/edgerouter-backup-$FNAME_BACKUP.tar.gz $SSH_USER@$SSH_HOST:$REPO_PATH/$FNAME_BACKUP.tar.gz > /dev/null

# git commit and git push on remote host
echo "edgerouter-backup: Triggering 'git commit'"
sudo ssh -q -i $SSH_KEYFILE -p $SSH_PORT -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $SSH_USER@$SSH_HOST 'bash -s' << ENDSSH > /dev/null
cd $REPO_PATH
git config user.email $GIT_EMAIL
git config user.name $GIT_NAME
git add $REPO_PATH/$FNAME_CONFIG
git add $REPO_PATH/$FNAME_CLI
git add $REPO_PATH/$FNAME_BACKUP.tar.gz
git commit -m "$GIT_COMMIT_MSG"
git push
ENDSSH

echo "edgerouter-backup: Complete"
