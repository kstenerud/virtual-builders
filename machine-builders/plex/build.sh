#!/bin/bash

set -e
SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options]"
options_set_help_flag_and_description H "Create a Plex container.

Note: mounts (-m) are specified in the format 'host_path:name' where:
    host_path = The host-side path to share
    name = name of the directory to mount in the guest under /mnt/media (so that it will be mounted as /mnt/media/name)."
options_add_switch c path "Mount the configuration directory" required
options_add_switch m path "Mount a media directory" required
options_add_switch n name   "Container name"          required $(basename $(readlink -f "$SCRIPT_HOME"))
options_read_arguments $@

CONTAINER_DISTRO=bionic
CONTAINER_NAME=$(options_get_value n)
SHARED_DIRECTORIES=$(options_get_values m)
CONFIG_DIRECTORY=$(options_get_value c)
MOUNT_PATHS=()
MOUNT_INDEX=1

get_next_mount_name()
{
	variable=$1
	mount_name="mount$MOUNT_INDEX"
	MOUNT_INDEX=$(( $MOUNT_INDEX + 1 ))
	eval ${variable}=$(echo $mount_name)
}

lxc_build_standard_container $CONTAINER_DISTRO $CONTAINER_NAME

lxc_mount_host plexconfig "$CONFIG_DIRECTORY" "/var/lib/plexmediaserver" r

for i in $SHARED_DIRECTORIES; do
	params=($(get_colon_separated_arguments 2 $i))
	if [ ${#params[@]} -eq 0 ]; then
		echo "Invalid -m format."
		options_print_help_and_exit 1
	fi
	host_path=${params[0]}
	name=${params[1]}
	guest_path="/mnt/media/$name"

	echo "Mounting host path [$host_path] as $guest_path"
	lxc_mount_host $name "$host_path" "$guest_path" r
	MOUNT_PATHS+=("$guest_path")
done

echo "Sleeping 5 seconds to give network time to come up..."
sleep 5
lxc_run_installer_script ${MOUNT_PATHS[@]}
