#!/bin/bash

[[ -z ${DOTBASE:-} ]] && DOTBASE=$HOME/.dotfiles

# Source function utils
. $HOME/.dotfiles/functions/utils.sh

#
##
###
#############
# Variables #
#############
###
##
#

FILENAME=$(basename "$0" .sh)

WEBSERVER_DROPLET_ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STARTING_PATH=$PWD

# Check for USERNAME and set it if not found
[[ -z ${USERNAME:-} ]] && USERNAME=${SUDO_USER:-$USER}

#
##
###
#############
# Functions #
#############
###
##
#

# Make sure script is run as root.
FILENAME=$(basename "$0" .sh)
run_as_root $FILENAME

usage_info() {
    BLNK=$(echo "$FILENAME" | sed 's/./ /g')
    echo "Usage: $FILENAME [{-s} site-name] [{-w} wordpress] \\"
    echo -e "\n        e.g. $(magenta sudo ./$FILENAME -s api.example.com -w)"

}

usage() {
    exec 1>2 # Send standard output to standard error
    usage_info
    exit 1
}

error() {
    echo -e "$FILENAME: $*" >&2
    exit 1
}

help() {
    usage_info
    echo
    echo "  {-s} site-name     -- Site name to apply permission fix to."
    echo "  {-w} wordpress     -- (flag only) Add wordpress permission fixes."
    exit 0
}

#
##
###
################
# Script Flags #
################
###
##
#

while getopts 'hws:' flag; do
    case "$flag" in
    h) help ;;
    w) WORDPRESS="true" ;;
    s) SITE_NAME="${OPTARG}" ;;
    *)
        usage_info
        exit 1
        ;;
    esac
done

# Check for all required arguments
[[ -z ${SITE_NAME:-} ]] && {
    echo "Must provide the site name."
    help
}

#
##
###
##########
# Script #
##########
###
##
#

cd /sites/$SITE_NAME

chown -R www-data logs
chown -R $USERNAME files

if [[ "$WORDPRESS" ]]; then
    chown -R www-data files/public/content/uploads
fi
