#!/bin/bash
# --------------------------------------------------
# Author: Rishi
#
# Description:
# This script is designed to setup the homelab's general configuration, this includes:
# 1. Setting up the cronjobs
# 2. Creating the necessary folders
# 3. Update script permissions to be executable
# 4. SSH Authentication management
# 5. Set MOTD
# --------------------------------------------------

# SSH Configuration
echo "SSH configuration starting..."
echo | ssh-keygen -P ''
echo "Please enter your SSH Key:"
read sshvar
echo "$sshvar" >> ~/.ssh/authorized_keys
echo "SSH Key updated"
sleep 1
echo "Do you have another SSH key to add?"
read sshanothervar
if [[ ${sshanothervar} == @(Yes|yes) ]]
then
  echo "Please enter it now: "
  read anothersshvar
  echo "$anothersshvar" >> ~/.ssh/authorized_keys
  echo "2nd SSH key added"
fi

echo "Turning Off Password Authentication..."
cd /etc/ssh && sed -i 's/#   PasswordAuthentication yes/    PasswordAuthentication no/g' ssh_config && sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' sshd_config
sed -i 's#Include /etc/ssh/ssh_config\.d/\*\.conf##g' ssh_config && sed -i 's#Include /etc/ssh/sshd_config\.d/\*\.conf##g' sshd_config
echo "Password Authentication Disabled"
sudo systemctl restart ssh

# MOTD

sudo echo "
██╗  ██╗ █████╗ ██╗  ██╗██████╗ ██╗███████╗██╗  ██╗██╗
██║  ██║██╔══██╗██║ ██╔╝██╔══██╗██║██╔════╝██║  ██║██║
███████║███████║█████╔╝ ██████╔╝██║███████╗███████║██║
██╔══██║██╔══██║██╔═██╗ ██╔══██╗██║╚════██║██╔══██║██║
██║  ██║██║  ██║██║  ██╗██║  ██║██║███████║██║  ██║██║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝╚═╝
" >> /etc/motd`



# Update Permissions

chmod +x /root/HomeLab/scripts/updates.sh
chmod +x /root/HomeLab/scripts/docker-backups.sh

# CronJob Creation

# Runs updates on the system at 00:00am on the 1st of each month
echo "0 0 1 * * /root/HomeLab/scripts/updates.sh" | crontab -

# Creates a backup of Docker data on Monday at 01:00am
echo "0 1 * * 1 /root/HomeLab/scripts/docker-backups.sh" | crontab -

# Folder Creation

mkdir /root/docker-backups
mkdir /media/TV-Shows
mkdir /media/Movies
mkdir /media/Music