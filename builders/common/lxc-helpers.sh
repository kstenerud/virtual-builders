LXC_HELPERS_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
source "$LXC_HELPERS_HOME/util.sh"

LXC_CONTAINER_DISTRO=
LXC_CONTAINER_NAME=
LXC_INTERPRETER=
LXC_STORAGE_POOL=default

declare -A LXC_CONTAINER_INTERPRETERS
set +u
LXC_CONTAINER_INTERPRETERS[alpine]=/bin/sh
LXC_CONTAINER_INTERPRETERS[ubuntu]=/bin/bash
set -u

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

lxc_new_container()
{
	LXC_CONTAINER_DISTRO=$1
	LXC_CONTAINER_NAME=$2
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
	echo "set -eu" >> $src_script
    cat "${LXC_HELPERS_HOME}/${LXC_CONTAINER_DISTRO}-helpers.sh" "$user_script" >> $src_script
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

lxc_mount_path()
{
	echo "mount $1 $2 $3"
	name=$1
	host_path=$2
	guest_path=$3
	lxc exec $LXC_CONTAINER_NAME -- mkdir -p "$guest_path"
	lxc config device add $LXC_CONTAINER_NAME $name disk source="$host_path" path="$guest_path"
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
