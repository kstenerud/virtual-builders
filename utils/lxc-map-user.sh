#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../common/lxc-helpers.sh "$SCRIPT_HOME"
set -u


if [ $# != 5 ]; then
   	echo "Usage: $0 <container> <guest user>:<guest group>:<host user>:<host group>"
   	echo "For example: $0 mycontainer root:root:someuser:someuser"
   	exit 1
fi

lxc_select_container_name $1
lxc_add_uid_gid_map $2
