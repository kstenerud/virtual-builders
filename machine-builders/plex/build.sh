#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

lxc_preconfigure bionic 1000 1000 "Create a Plex container.

Note: mounts (-m) are specified in the format 'host_path:name' where:
    host_path = The host-side path to share
    name = name of the directory to mount in the guest under /mnt/media
           (so that it will be mounted as /mnt/media/name)." L R U
options_add_switch c path "Mount the configuration directory" required
options_add_switch m path "Mount a media directory"           required
lxc_run_standard_preinstall $@
lxc_apply_command_line_arguments

MEDIA_MOUNTS="$(options_get_values m)"
CONFIG_MOUNT="$(options_get_value c)"
MOUNT_PATHS=()

lxc_mount_host config "$CONFIG_MOUNT" "/var/lib/plexmediaserver" w

for i in $MEDIA_MOUNTS; do
	params=($(get_colon_separated_arguments 2 $i))
	if [ ${#params[@]} -eq 0 ]; then
		echo "Invalid -m format."
		options_print_help_and_exit 1
	fi
	host_path="${params[0]}"
	name="${params[1]}"
	guest_path="/mnt/media/$name"

	echo "Mounting host path [$host_path] as $guest_path"
	lxc_mount_host "$name" "$host_path" "$guest_path" r
	MOUNT_PATHS+=("$guest_path")
done

lxc_run_installer_script ${MOUNT_PATHS[@]}
