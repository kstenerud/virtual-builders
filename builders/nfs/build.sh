#!/bin/bash

# To mount an NFS share:
# mount -t nfs host:/host/side/path /client/side/mount/path

set -eu

SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/../common/lxc-helpers.sh
source $SCRIPT_HOME/../common/options.sh

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options]"
options_set_help_flag_and_description H "Create an NFS file sharing container.

Note: share mounts (-m) are specified in the format 'path:name:address:readwrite' where:
    path = The host-side path to share
    name = The name that the share will be presented as
    address = IP address(es) to share to
    readwrite = either 'r' for read-only or 'w' for read-write

The 'address' field supports wildcards. For example:
    192.168.0.15 = only share to this one address
    192.168.9.*  = share to anyone on the 192.168.0.* subnet
    *            = share to everyone"
options_add_switch m number "Mount a directory for sharing" required /mnt/shared
options_add_switch n name "Specify the container's name" required nfs
options_read_arguments $@

CONTAINER_NAME=$(options_get_value n)
CONTAINER_DISTRO=alpine
SHARED_DIRECTORIES=$(options_get_values m)
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
lxc_mark_privileged
lxc profile set default raw.apparmor "mount fstype=nfs,
mount fstype=nfs4,
mount fstype=nfsd,
mount fstype=rpc_pipefs,"
lxc restart $CONTAINER_NAME

for i in $SHARED_DIRECTORIES; do
	host_path=$(echo $i|sed 's/\([^:]*\):.*/\1/g')
	name=$(echo $i|sed 's/[^:]*:\([^:]*\):.*/\1/g')
	address=$(echo $i|sed 's/[^:]*:[^:]*:\([^:]*\):.*/\1/g')
	readwrite=$(echo $i|sed 's/[^:]*:[^:]*:[^:]*:\([^:]*\).*/\1/g')

	if [ "$host_path" == "$i" ] || [ "$name" == "$i" ] || [ "$address" == "$i" ] || [ "$readwrite" == "$i" ]; then
		echo "Invalid -m format."
		options_print_help
		exit 1
	fi

	if [ "$readwrite" != "r" ] && [ "$readwrite" != "w" ]; then
		echo "Invalid read/write flag: $readwrite. Allowed values are r and w"
		options_print_help
		exit 1
	fi

	echo "Mounting host path [$host_path] as $name for address $address, mode $readwrite"
	guest_path="/exports/$name"
	lxc_mount_path $name "$host_path" "$guest_path"
	MOUNT_PATHS+=("$guest_path:$address:$readwrite")
done

lxc_run_installer_script ${MOUNT_PATHS[@]}
