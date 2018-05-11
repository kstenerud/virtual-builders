INCLUDED_SH=INCLUDED_d919491ac20c4579a97c90c770536ff4; if [ ! -z ${!INCLUDED_SH} ]; then return 0; fi; eval ${INCLUDED_SH}=true

LXC_SOURCE_HOME="$1"
LXC_HELPERS_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
source "$LXC_HELPERS_HOME/util.sh"

LXC_CONTAINER_DISTRO=
LXC_CONTAINER_NAME=
LXC_INTERPRETER=
LXC_STORAGE_POOL=default

declare -A LXC_CONTAINER_INTERPRETERS
LXC_CONTAINER_INTERPRETERS[alpine]=/bin/sh
LXC_CONTAINER_INTERPRETERS[ubuntu]=/bin/bash

lxc_get_container_init_args()
{
	args=
	if [ "$LXC_STORAGE_POOL" != "default" ]; then
		args="$args -s $LXC_STORAGE_POOL"
	fi
	echo $args
}

lxc_init_distro_alpine()
{
    lxc launch images:alpine/3.7 $LXC_CONTAINER_NAME $(lxc_get_container_init_args)
    lxc exec $LXC_CONTAINER_NAME -- sed -i 's/^tty/#tty/g' /etc/inittab
    lxc stop $LXC_CONTAINER_NAME
}

lxc_init_distro_ubuntu()
{
    lxc init images:ubuntu/bionic $LXC_CONTAINER_NAME $(lxc_get_container_init_args)
}

lxc_set_container() {
	LXC_CONTAINER_NAME=$1
}

lxc_new_container()
{
	LXC_CONTAINER_DISTRO=$1
	lxc_set_container $2
	echo "Creating new $LXC_CONTAINER_DISTRO distribution called $LXC_CONTAINER_NAME"
	set +u
	LXC_INTERPRETER=${LXC_CONTAINER_INTERPRETERS[$LXC_CONTAINER_DISTRO]}
	set -u
	lxc_init_distro_$LXC_CONTAINER_DISTRO
}

lxc_start_container()
{
	lxc start $LXC_CONTAINER_NAME
	# Give time for networking to start
	sleep 1
}

lxc_mark_privileged()
{
    lxc config set $LXC_CONTAINER_NAME security.privileged true
}

lxc_exec()
{
	lxc exec $LXC_CONTAINER_NAME $@
}

lxc_copy_dir_into_container()
{
	srcdir=$1
	dstdir=$2
	pushd "$srcdir"
	tar cf - . | lxc exec $LXC_CONTAINER_NAME -- tar xf - -C "$dstdir"
	popd

}

lxc_copy_dir_into_container_if_exists()
{
	srcdir=$1
	dstdir=$2

	if [ -d "$srcdir" ]; then
		lxc_copy_dir_into_container "$srcdir" "$dstdir"
	fi
}

lxc_copy_fs()
{
	lxc_copy_dir_into_container_if_exists "$LXC_SOURCE_HOME/fs" /
}

lxc_run_script()
{
	user_script=$1
	shift
	script_name=lxc_script_$(generate_uuid).sh
	src_script=/tmp/$script_name
    dst_script=/tmp/$script_name

	echo "#!${LXC_INTERPRETER}" > $src_script
    tail -n +2 "${LXC_HELPERS_HOME}/${LXC_CONTAINER_DISTRO}-helpers.sh" >> $src_script
    tail -n +2 "${LXC_HELPERS_HOME}/util.sh" >> $src_script
	echo "set -eu" >> $src_script
    cat "$user_script" >> $src_script
    echo "" >> $src_script
    chmod a+x $src_script
    lxc file push $src_script $LXC_CONTAINER_NAME/$dst_script
    rm $src_script
    lxc exec $LXC_CONTAINER_NAME -- $LXC_INTERPRETER $dst_script $@
#    lxc exec $LXC_CONTAINER_NAME -- rm $dst_script
}

lxc_fix_unprivileged_dbus()
{
    # Fix to make dbus work correctly on non-privileged containers
    lxc config device add $LXC_CONTAINER_NAME fuse unix-char major=10 minor=229 path=/dev/fuse
}

lxc_mount_network_bridge()
{
	bridge=$1
	lxc config device add $LXC_CONTAINER_NAME eth1 nic name=eth1 nictype=bridged parent=$bridge
}

lxc_add_to_fstab()
{
	lxc exec $LXC_CONTAINER_NAME -- sh -c "echo \"$1\" >> /etc/fstab"
}

lxc_mount_cifs() {
	# requires cifs-utils
	server=$1
	share_path=$2
	mount_point=$3
	read_write=$4

	lxc exec $LXC_CONTAINER_NAME -- mkdir -p "$mount_point"
	lxc_add_to_fstab "//$server/$share_path  \"$mount_point\"  cifs  guest,uid=1000,iocharset=utf8  0  0"
	lxc exec $LXC_CONTAINER_NAME -- mount "$mount_point"
}

lxc_mount_nfs() {
	# requires nfs-common
	server=$1
	share_path=$2
	mount_point=$3
	read_write=$4

	lxc exec $LXC_CONTAINER_NAME -- mkdir -p "$mount_point"
	lxc_add_to_fstab "$server:\"$share_path\"  \"$mount_point\"  nfs  rsize=8192,wsize=8192,timeo=14,hard,intr,noexec,nosuid  0  0"
	lxc exec $LXC_CONTAINER_NAME -- mount "$mount_point"
}

lxc_mount_sshfs() {
	user_at_server=$1
	share_path=$2
	mount_point=$3
	read_write=$4

	lxc exec $LXC_CONTAINER_NAME -- mkdir -p "$mount_point"
	lxc_add_to_fstab "$user_at_server:\"$share_path\"  \"$mount_point\"  fuse.sshfs  defaults,_netdev  0  0"
	lxc exec $LXC_CONTAINER_NAME -- mount "$mount_point"
}

lxc_mount_host() {
	device_name=$1
	host_path=$2
	mount_point=$3
	read_write=$4

	lxc exec $LXC_CONTAINER_NAME -- mkdir -p "$mount_point"
	lxc config device add $LXC_CONTAINER_NAME $device_name disk source="$host_path" path="$mount_point"
}

lxc_mount_print_help() {
	echo "Mount format: protocol:server:share_path:mount_point:r_or_w"
	echo "Examples:"
	echo "    smb:my_samba_server:shared_stuff:/mnt/from_samba:r"
    echo "    nfs:my_nfs_server:/home/joe:/mnt/home/joe:w"
    echo "    host:a_unique_name:/home/sam:/home/sam:w"
    echo "    sshfs:me@server.com:/home/me/shared:/mnt/shared:r"
    echo
    echo "Note: Mounting smb and nfs shares are broken (Operation not permitted)."
    echo "This probably has something to do with the mount command inside containers."
}

## Expected Format:
# protocol:server:share_path:mount_point:rw
lxc_mount() {
	params=( $(echo $1|sed 's/\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\):\(.*\)/\1 \2 \3 \4 \5/g') )
	if [ ${#params[@]} -ne 5 ]; then
		echo "Invalid mount info format. Must be protocol:server:share_path:mount_point:r_or_w"
		return 1
	fi
	protocol=${params[0]}
	server=${params[1]}
	host_path=${params[2]}
	mount_point=${params[3]}
	read_write=${params[4]}

	if [ "$read_write" != "r" ] && [ "$read_write" != "w" ]; then
		echo "Invalid read/write flag: $read_write. Allowed values are r and w"
		return 1
	fi

	case $protocol in
		cifs )
			lxc_mount_cifs $server "$host_path" "$mount_point" $read_write ;;
		smb )
			lxc_mount_cifs $server "$host_path" "$mount_point" $read_write ;;
		nfs )
			lxc_mount_nfs $server "$host_path" "$mount_point" $read_write ;;
		sshfs )
			lxc_mount_sshfs $server "$host_path" "$mount_point" $read_write ;;
		host )
			lxc_mount_host $server "$host_path" "$mount_point" $read_write ;;
		* )
			echo "$protocol: Unknown protocol"
			return 1
			;;
	esac
}

lxc_run_installer_script()
{
	lxc_run_script "$LXC_SOURCE_HOME/installer.sh" $@
}

lxc_build_standard_container()
{
	distro=$1
	name=$2
	lxc_new_container $distro $name
	lxc_start_container
	lxc_copy_fs
}
