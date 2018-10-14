#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../common/lxc-helpers.sh "$SCRIPT_HOME"
set -u

if [ $# -ne 2 ]; then
	echo "Usage: %0 <container name> <mount info>"
	echo
	lxc_mount_print_help
    exit 1
fi

CONTAINER_NAME="$1"
MOUNT="$2"

lxc_select_container_name $CONTAINER_NAME
lxc_mount "$MOUNT"
