#!/bin/bash
# --------------------------------------------------
# Author: Rishi
#
# 1. Updates the package list
# 2. Upgrades all installed packages to the latest version
# 3. Installs any security updates
# 4. Remove any unused packages
# --------------------------------------------------

echo "Script Starting..."

sudo apt-get update

sudo apt-get upgrade -y

sudo apt-get dist-upgrade -y

sudo apt-get autoremove -y

echo "Script complete!"