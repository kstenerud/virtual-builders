#!/bin/bash

# To mount an NFS share:
# mount -t nfs host:/host/side/path /client/side/mount/path

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

lxc_preconfigure alpine 0 0 "Create an NFS file sharing container.

Note: share mounts (-m) are specified in the format 'host_path:name:address:readwrite' where:
    host_path = The host-side path to share
    name = The name under which the share will be presented in nfs (/exports/name)
    address = IP address(es) to share to
    readwrite = either 'r' for read-only or 'w' for read-write

The 'address' field supports wildcards. For example:
    192.168.0.15 = only share to this one address
    192.168.9.*  = share to anyone on the 192.168.0.* subnet
    *            = share to everyone" L U
options_add_switch m path "Mount a directory for sharing" required
lxc_run_standard_preinstall $@
lxc_mark_privileged
lxc profile set default raw.apparmor "mount fstype=nfs,
mount fstype=nfs4,
mount fstype=nfsd,
mount fstype=rpc_pipefs,"
lxc_apply_command_line_arguments

CONTAINER_NAME="$(options_get_value n)"
SHARED_DIRECTORIES="$(options_get_values m)"
MOUNT_PATHS=()

for i in $SHARED_DIRECTORIES; do
	# Don't interpret * as a glob.
	set -f
	params=($(get_colon_separated_arguments 4 $i))
	set +f
	if [ ${#params[@]} -eq 0 ]; then
		echo "Invalid -m format."
		options_print_help_and_exit 1
	fi
	host_path="${params[0]}"
	ensure_directory_exists "$host_path"
	name="${params[1]}"
	address="${params[2]}"
	readwrite="${params[3]}"
	echo "params ${#params[@]}, host_path $host_path, name $name, address $address, readwrite ${params[3]}"

	if [ "$readwrite" != "r" ] && [ "$readwrite" != "w" ]; then
		echo "Invalid read/write flag: $readwrite. Allowed values are r and w"
		options_print_help_and_exit 1
	fi

	echo "Mounting host path [$host_path] as $name for address $address, mode $readwrite"
	guest_path="/exports/$name"
	lxc_mount_host $name "$host_path" "$guest_path" $readwrite
	MOUNT_PATHS+=("$guest_path:$address:$readwrite")
done

lxc_run_installer_script ${MOUNT_PATHS[@]}
