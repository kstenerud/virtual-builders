#!/bin/bash

set -eu

SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
LXC_SOURCE_HOME="$SCRIPT_HOME"
source $SCRIPT_HOME/../common/lxc-helpers.sh
source $SCRIPT_HOME/../common/options.sh

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options]"
options_set_help_flag_and_description H "Create a Samba file sharing container.

Note: share mounts (-m) are specified in the format 'path:name:readwrite' where:
    path = The host-side path to share
    name = The name that the share will be presented as
    readwrite = either 'r' for read-only or 'w' for read-write"
options_add_switch m number "Mount a directory for sharing" required /mnt/shared:shared:r
options_add_switch n name "Specify the container's name" required samba
options_read_arguments $@

CONTAINER_NAME=$(options_get_value n)
CONTAINER_DISTRO=alpine
SHARED_DIRECTORIES=$(options_get_values m)
MOUNT_PATHS=()

lxc_build_standard_container $CONTAINER_DISTRO $CONTAINER_NAME

for i in $SHARED_DIRECTORIES; do
	host_path=$(echo $i|sed 's/\([^:]*\):.*/\1/g')
	name=$(echo $i|sed 's/[^:]*:\([^:]*\):.*/\1/g')
	readwrite=$(echo $i|sed 's/[^:]*:[^:]*:\([^:]*\).*/\1/g')

	if [ -z "$host_path" ] || [ -z "$name" ] || [ -z "$readwrite" ]; then
		echo "Invalid -m format."
		echo "Proper format is: /host/path:name:r or /host/path:name:w"
		exit 1
	fi

	if [ "$readwrite" != "r" ] && [ "$readwrite" != "w" ]; then
		echo "Invalid read/write flag: $readwrite"
		echo "Allowed values are r and w"
		echo "Proper format is: /host/path:name:r or /host/path:name:w"
		exit 1
	fi

	echo "Mounting host path [$host_path] as $name, mode $readwrite"
	guest_path="/mnt$(readlink -f "$host_path")"
	lxc_mount_path $name "$host_path" "guest_path"
	MOUNT_PATHS+=("$guest_path:$name:$readwrite")
done

lxc_run_installer_script ${MOUNT_PATHS[@]}
