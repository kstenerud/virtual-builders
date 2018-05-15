#!/bin/bash

set -e
SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
source $SCRIPT_HOME/../../common/util.sh
set -u

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options]"
options_set_help_flag_and_description H "Create a Samba file sharing container.

Note: share mounts (-m) are specified in the format 'path:name:readwrite' where:
    path = The host-side path to share
    name = The name that the share will be presented as
    readwrite = either 'r' for read-only or 'w' for read-write"
options_add_switch m number "Mount a directory for sharing" required /mnt/shared:shared:r
options_add_switch n name   "Container name"                required $(basename $(readlink -f "$SCRIPT_HOME"))
options_read_arguments $@

CONTAINER_DISTRO=alpine
CONTAINER_NAME=$(options_get_value n)
SHARED_DIRECTORIES=$(options_get_values m)
MOUNT_PATHS=()

lxc_build_standard_container $CONTAINER_DISTRO $CONTAINER_NAME

for i in $SHARED_DIRECTORIES; do
	params=($(get_colon_separated_arguments 3 $i))
	if [ ${#params[@]} -eq 0 ]; then
		echo "Invalid -m format."
		options_print_help_and_exit 1
	fi
	host_path=${params[0]}
	name=${params[1]}
	readwrite=${params[2]}

	if [ "$readwrite" != "r" ] && [ "$readwrite" != "w" ]; then
		echo "Invalid read/write flag: $readwrite. Allowed values are r and w"
		options_print_help_and_exit 1
	fi

	echo "Mounting host path [$host_path] as $name, mode $readwrite"
	guest_path="/mnt/samba/$name"
	lxc_mount_host $name "$host_path" "$guest_path" $readwrite
	MOUNT_PATHS+=("$guest_path:$name:$readwrite")
done

lxc_run_installer_script ${MOUNT_PATHS[@]}
