#!/bin/bash

set -e
SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/../common/lxc-helpers.sh "$SCRIPT_HOME"
set -u

if [ $# -ne 2 ]; then
	echo "Usage: %0 <container name> <mount info>"
	echo
	lxc_mount_print_help
    exit 1
fi

CONTAINER_NAME=$1
MOUNT=$2

lxc_set_container $CONTAINER_NAME
lxc_mount "$MOUNT"
