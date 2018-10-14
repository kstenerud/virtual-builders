#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
source $SCRIPT_HOME/../../common/util.sh
set -u

lxc_preconfigure edge 65534 65534 "Create a Samba file sharing container.

Note: share mounts (-m) are specified in the format 'path:share-name:readwrite' where:
    path = The host-side path to share
    share-name = The name that the share will be presented as
    readwrite = either 'r' for read-only or 'w' for read-write" L U
options_add_switch m path "Mount a directory for sharing" required
lxc_run_standard_preinstall $@
lxc_apply_command_line_arguments

SHARED_DIRECTORIES=$(options_get_values m)
MOUNT_PATHS=()

for i in $SHARED_DIRECTORIES; do
	# Don't interpret * as a glob.
	set -f
	params=($(get_colon_separated_arguments 3 $i))
	set +f
	if [ ${#params[@]} -eq 0 ]; then
		echo "Invalid -m format."
		options_print_help_and_exit 1
	fi
	host_path="${params[0]}"
	name="${params[1]}"
	readwrite="${params[2]}"

	if [ "$readwrite" != "r" ] && [ "$readwrite" != "w" ]; then
		echo "Invalid read/write flag: $readwrite. Allowed values are r and w"
		options_print_help_and_exit 1
	fi

	echo "Mounting host path [$host_path] as $name, mode $readwrite"
	guest_path="/mnt/samba/$name"
	lxc_mount_host $name "$host_path" "$guest_path" "$readwrite"
	MOUNT_PATHS+=("$guest_path:$name:$readwrite")
done

lxc_run_installer_script ${MOUNT_PATHS[@]}
