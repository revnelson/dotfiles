#!/bin/bash

#
##
###
#############
# Variables #
#############
###
##
#

# Check for USERNAME and set it if not found
[[ -z ${USERNAME:-} ]] && USERNAME=${SUDO_USER:-$USER}

export HOME_DIRECTORY="/home/${USERNAME}"

#
##
###
#############
# Functions #
#############
###
##
#

[[ -z ${DOTBASE:-} ]] && DOTBASE=$HOME_DIRECTORY/.dotfiles

# Source function utils
. $DOTBASE/functions/utils.sh

#
##
###
##########
# Script #
##########
###
##
#

print_section 'Installing NVM...'

echo "Updating apt sources..."
sudo apt_quiet update

NVM_VERSION="0.39.7"
export NVM_DIR=$HOME_DIRECTORY/.nvm
NVM_URL=https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh
echo "Installing NVM v$NVM_VERSION..."
mkdir -p $NVM_DIR
curl -s -o- $NVM_URL | NVM_DIR=$HOME_DIRECTORY/.nvm bash >/dev/null
chown -R $USERNAME:$USERNAME $NVM_DIR

echo "Installing required build dependencies..."
sudo apt_quiet install build-essential

echo "Installing latest LTS node version..."
echo "$(magenta 'This may take a long time if it needs to be compiled.')"

sudo -E -H -u "$USERNAME" bash <<'EOF'
\. "$NVM_DIR/nvm.sh"
nvm install --lts >/dev/null
nvm use node
echo "Installing global node packages..."
npm install -g npm yarn uuid pm2 encoding >/dev/null
EOF
