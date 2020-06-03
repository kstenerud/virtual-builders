INCLUDED_SH=INCLUDED_d919491ac20c4579a97c90c770536ff4; if [ ! -z ${!INCLUDED_SH} ]; then return 0; fi; eval ${INCLUDED_SH}=true

LXC_SOURCE_HOME="$1"
LXC_HELPERS_HOME=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
source "$LXC_HELPERS_HOME/util.sh"


# -------
# Globals
# -------

LXC_CONTAINER_TYPE=
LXC_CONTAINER_DISTRIBUTION=
LXC_CONTAINER_RELEASE=
LXC_CONTAINER_NAME=
LXC_CONTAINER_IMAGE=
LXC_CONTAINER_INTERPRETER=
LXC_CONTAINER_HELPERS_SCRIPT=
LXC_CONTAINER_USER=0
LXC_CONTAINER_GROUP=0
LXC_STORAGE_POOL=default


# -------
# Presets
# -------

declare -A LXC_TYPE_IMAGES
declare -A LXC_TYPE_DISTRIBUTIONS
declare -A LXC_TYPE_RELEASES
declare -A LXC_DISTRIBUTION_INTERPRETERS
declare -A LXC_DISTRIBUTION_HELPER_SCRIPTS

declare -A LXC_SWITCH_ARGUMENT
declare -A LXC_SWITCH_DESCRIPTION
declare -A LXC_SWITCH_REQUIRED
declare -A LXC_SWITCH_DEFAULT


lxc_i_add_type()
{
    type="$1"
    distribution="$2"
    release="$3"
    image="$4"

    LXC_TYPE_DISTRIBUTIONS[$type]="$distribution"
    LXC_TYPE_RELEASES[$type]="$release"
    LXC_TYPE_IMAGES[$type]="$image"
}

lxc_i_add_distrbution()
{
    distribution="$1"
    interpreter="$2"
    helper_script="$3"

    LXC_DISTRIBUTION_INTERPRETERS[$distribution]="$interpreter"
    LXC_DISTRIBUTION_HELPER_SCRIPTS[$distribution]="$helper_script"
}

lxc_i_add_distrbution  alpine  /bin/sh    alpine-helpers.sh
lxc_i_add_distrbution  ubuntu  /bin/bash  ubuntu-helpers.sh

lxc_i_add_type  alpine  alpine 3.7    images:alpine/3.7
lxc_i_add_type  edge    alpine edge   images:alpine/edge
lxc_i_add_type  ubuntu  ubuntu focal  ubuntu-daily:focal
lxc_i_add_type  focal   ubuntu focal  ubuntu-daily:focal
lxc_i_add_type  bionic  ubuntu bionic ubuntu-daily:bionic
lxc_i_add_type  cosmic  ubuntu cosmic ubuntu-daily:cosmic
lxc_i_add_type  xenial  ubuntu xenial ubuntu-daily:xenial

lxc_add_standard_switch()
{
    switch="$1"
    LXC_SWITCH_ARGUMENT[$switch]="$2"
    LXC_SWITCH_DESCRIPTION[$switch]="$3"
    LXC_SWITCH_REQUIRED[$switch]="$4"
    LXC_SWITCH_DEFAULT[$switch]="$5"
}

lxc_add_standard_flag()
{
    switch="$1"
    LXC_SWITCH_DESCRIPTION[$switch]="$2"
    LXC_SWITCH_REQUIRED[$switch]="$3"
}

lxc_add_standard_switch b bridge   "The bridge to connect to"       required  br0
lxc_add_standard_switch C resolution "Chrome Remote Desktop resolution (XxY)"  required 1920x1080
lxc_add_standard_flag   K          "Add KVM support"                optional
lxc_add_standard_switch L locale   "Language:region:kb_layout:kb_model:timezone (ex: en:US:us:pc105:America/Vancouver)" optional
lxc_add_standard_flag   N          "Make container nestable"        optional
lxc_add_standard_switch p password "Password for the new user"      required  ubuntu
lxc_add_standard_flag   P          "Make container privileged"      optional
lxc_add_standard_switch R url      "Use a custom repository mirror" optional
lxc_add_standard_switch u username "Name of user to create"         required  ubuntu
lxc_add_standard_switch U usermap  "Map to host user (user:group)"  optional


# --------------
# Initialization
# --------------

lxc_select_container_name()
{
    LXC_CONTAINER_NAME="$1"
}

lxc_select_container_type()
{
    type="$1"

    LXC_CONTAINER_TYPE="$type"
    set +u
    LXC_CONTAINER_IMAGE="${LXC_TYPE_IMAGES[$type]}"
    LXC_CONTAINER_DISTRIBUTION="${LXC_TYPE_DISTRIBUTIONS[$type]}"
    LXC_CONTAINER_RELEASE="${LXC_TYPE_RELEASES[$type]}"
    LXC_CONTAINER_INTERPRETER="${LXC_DISTRIBUTION_INTERPRETERS[$LXC_CONTAINER_DISTRIBUTION]}"
    LXC_CONTAINER_HELPERS_SCRIPT="${LXC_DISTRIBUTION_HELPER_SCRIPTS[$LXC_CONTAINER_DISTRIBUTION]}"
    set -u
}

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
    lxc launch $LXC_CONTAINER_IMAGE $LXC_CONTAINER_NAME $(lxc_get_container_init_args)
    lxc exec $LXC_CONTAINER_NAME -- sed -i 's/^tty/#tty/g' /etc/inittab
    lxc stop $LXC_CONTAINER_NAME
}

lxc_init_distro_ubuntu()
{
    lxc init $LXC_CONTAINER_IMAGE $LXC_CONTAINER_NAME $(lxc_get_container_init_args)
}

lxc_init_distro()
{
    echo "Creating new $LXC_CONTAINER_DISTRIBUTION $LXC_CONTAINER_RELEASE container called $LXC_CONTAINER_NAME"
    lxc_init_distro_$LXC_CONTAINER_DISTRIBUTION
}

lxc_new_container()
{
    name="$1"
    type="$2"

    lxc_select_container_name $name
    lxc_select_container_type $type
    lxc_init_distro
}

lxc_start_container()
{
    lxc start $LXC_CONTAINER_NAME
}

lxc_set_user_group()
{
    LXC_CONTAINER_USER="$1"
    LXC_CONTAINER_GROUP="$2"
}

lxc_preconfigure()
{
    type="$1"
    shift
    user="$1"
    shift
    group="$1"
    shift
    description="$1"
    shift
    echo "Preconfiguring container type $type with user:group $user:$group and args $@"

    options_set_usage "$(basename $LXC_SOURCE_HOME) [options]"
    options_set_help_flag_and_description H "$description"
    options_add_switch n name "Container name" required $(basename $(readlink -f "$LXC_SOURCE_HOME"))

    for switch in $@; do
        set +u
        argument="${LXC_SWITCH_ARGUMENT[$switch]}"
        description="${LXC_SWITCH_DESCRIPTION[$switch]}"
        required="${LXC_SWITCH_REQUIRED[$switch]}"
        default_value="${LXC_SWITCH_DEFAULT[$switch]}"
        set -u
        if [ ! -z "$description" ]; then
            if [ -z "$argument" ]; then
                options_add_flag $switch "$description" $required
            else
                options_add_switch $switch $argument "$description" $required "$default_value"
            fi
        fi
    done

    lxc_set_user_group $user $group
    lxc_select_container_type $type
}

lxc_run_standard_preinstall()
{
    options_read_arguments $@
    lxc_select_container_name "$(options_get_value n)"
    lxc_init_distro
    lxc_start_container
    lxc_copy_fs
}

lxc_apply_command_line_arguments()
{
    if [ ! -z "$(options_get_value P)" ]; then lxc_mark_privileged;                                 fi
    if [ ! -z "$(options_get_value N)" ]; then lxc_allow_nesting;                                   fi
    if [ ! -z "$(options_get_value K)" ]; then lxc_allow_kvm;                                       fi
    if [ ! -z "$(options_get_value U)" ]; then lxc_map_guest_user_to_host "$(options_get_value U)"; fi
    sleep 1
    lxc_restart
    lxc_wait_for_network
    if [ ! -z "$(options_get_value R)"  ]; then
        lxc_use_custom_mirror "$(options_get_value R)";
    else
        lxc_update_packages
    fi
    if [ ! -z "$(options_get_value L)" ];  then lxc_set_locale_kb_tz "$(options_get_value L)";      fi
}


# -----
# Utils
# -----

lxc_restart()
{
    echo "Stopping $LXC_CONTAINER_NAME"
    lxc stop --timeout 20 $LXC_CONTAINER_NAME
    sleep 1
    echo "Restarting $LXC_CONTAINER_NAME"
    lxc start $LXC_CONTAINER_NAME
}

lxc_get_config()
{
    lxc config get $LXC_CONTAINER_NAME $@
}

lxc_set_config()
{
    lxc config set $LXC_CONTAINER_NAME $@
}

lxc_exec()
{
    lxc exec $LXC_CONTAINER_NAME -- $@
}

lxc_generate_temp_file_name()
{
    echo "/tmp/lxc_temp_file_delete_me_$(generate_uuid)"
}

lxc_run_script()
{
    user_script="$1"
    shift
    src_script="$(lxc_generate_temp_file_name)"
    dst_script="$src_script"

    echo "#!${LXC_CONTAINER_INTERPRETER}" > $src_script
    echo "set -eu" >> $src_script
    tail -n +2 "${LXC_HELPERS_HOME}/${LXC_CONTAINER_HELPERS_SCRIPT}" >> $src_script
    tail -n +2 "${LXC_HELPERS_HOME}/util.sh" >> $src_script
    echo "" >> $src_script
    echo "" >> $src_script
    cat "$user_script" >> $src_script
    echo "" >> $src_script
    chmod a+x $src_script
    lxc file push $src_script $LXC_CONTAINER_NAME$dst_script
    rm $src_script
    lxc exec $LXC_CONTAINER_NAME -- $LXC_CONTAINER_INTERPRETER $dst_script $@
    lxc exec $LXC_CONTAINER_NAME -- rm $dst_script
}

lxc_get_default_ip_address()
{
    # Using sed + grep instead of awk since alpine may not have it.
    default_iface=$(lxc_exec grep "^\w*\s*00000000" /proc/net/route | sed 's/\([a-z0-9]*\).*/\1/')
    lxc_exec ip addr show dev "$default_iface" | grep "inet " | sed 's/[^0-9]*\([0-9.]*\).*/\1/'
}


# ------------
# Repositories
# ------------

lxc_is_ubuntu_repository()
{
    url="$1"
    release_url="$url/dists/$LXC_CONTAINER_RELEASE/Release"
    curl --output /dev/null --silent --head --fail "$release_url"
}

lxc_use_custom_mirror_ubuntu()
{
    mirror_url="$1"
    release="$LXC_CONTAINER_RELEASE"

    if ! lxc_is_ubuntu_repository "$mirror_url"; then
        original_url="$mirror_url"
        mirror_url="$mirror_url/ubuntu/"
        if ! lxc_is_ubuntu_repository "$mirror_url"; then
            echo "Error: [$original_url] is not an ubuntu $release repository."
            return 1
        fi
    fi

    lxc_prepend_file /etc/apt/sources.list \
    "deb [ arch=amd64 ] $mirror_url $release main restricted
deb [ arch=amd64 ] $mirror_url $release universe
deb [ arch=amd64 ] $mirror_url $release multiverse
deb [ arch=amd64 ] $mirror_url $release-updates main restricted
deb [ arch=amd64 ] $mirror_url $release-updates universe
deb [ arch=amd64 ] $mirror_url $release-updates multiverse
deb [ arch=amd64 ] $mirror_url $release-security main restricted
deb [ arch=amd64 ] $mirror_url $release-security universe
deb [ arch=amd64 ] $mirror_url $release-security multiverse
"
    lxc_update_packages
}

lxc_update_packages_ubuntu()
{
    lxc_exec apt update
}

lxc_update_packages_alpine()
{
    lxc_exec apk update
}

lxc_use_custom_mirror()
{
    lxc_use_custom_mirror_$LXC_CONTAINER_DISTRIBUTION $@
}

lxc_update_packages()
{
    lxc_update_packages_$LXC_CONTAINER_DISTRIBUTION $@
}


# ----
# UIDs
# ----

lxc_warn_if_uid_gid_map_not_enabled()
{
    id="$1"
    file="$2"

    user=root
    while read line; do
        if [ -z "$line" ]; then continue; fi
        fields=($(get_colon_separated_arguments 3 $line))
        if [ "${fields[0]}" != "$user" ]; then continue; fi
        if [ "${fields[1]}" == "$id" ]; then return; fi
    done < "$file"
    echo "WARNING: You'll need to add permission for $user to share id $id in $file:"
    echo "    $user:$id:1"
    echo "The container may fail to build without it."
}

lxc_get_host_uid()
{
    if is_numeric "$1"; then
        echo $1
    else
        id -u "$1"
    fi
}

lxc_get_host_gid()
{
    if is_numeric "$1"; then
        echo $1
    else
        id -g "$1"
    fi
}

lxc_get_guest_uid()
{
    if is_numeric "$1"; then
        echo $1
    else
        lxc_exec id -u "$1"
    fi
}

lxc_get_guest_gid()
{
    if is_numeric "$1"; then
        echo $1
    else
        lxc_exec id -g "$1"
    fi
}

lxc_check_map_user()
{
    lxc_warn_if_uid_gid_map_not_enabled $(lxc_get_host_uid $1) /etc/subuid
}

lxc_check_map_group()
{
    lxc_warn_if_uid_gid_map_not_enabled $(lxc_get_host_gid $1) /etc/subgid
}

lxc_generate_uid_map()
{
    guest_uid="$(lxc_get_guest_uid $1)"
    host_uid="$(lxc_get_host_uid $2)"

    idmap="$(lxc config get $LXC_CONTAINER_NAME raw.idmap)"
        if [ ! -z "$idmap" ]; then
            echo "$idmap"
        fi
    echo "uid $host_uid $guest_uid"
}

lxc_generate_gid_map()
{
    guest_gid="$(lxc_get_guest_gid $1)"
    host_gid="$(lxc_get_host_gid $2)"

    echo "gid $host_gid $guest_gid"
}

lxc_generate_uid_gid_map()
{
    guest_user="$1"
    host_user="$2"
    guest_group="$3"
    host_group="$4"

    lxc_generate_uid_map $guest_user $host_user
    lxc_generate_gid_map $guest_group $host_group
}

lxc_add_uid_gid_map()
{
    # Format guest-user:guest-group:host-user:host-group
    fields=($(get_colon_separated_arguments 4 $1))
    guest_user="${fields[0]}"
    guest_group="${fields[1]}"
    host_user="${fields[2]}"
    host_group="${fields[3]}"

    lxc_check_map_user $host_user
    lxc_check_map_group $host_group
    lxc config set $LXC_CONTAINER_NAME raw.idmap "$(lxc_generate_uid_gid_map $guest_user $host_user $guest_group $host_group)"
}

lxc_map_guest_user_to_host()
{
    # Format user:group, by name (nobody:nogroup) or number (1000:1000)
    echo "Mapping guest user:group $LXC_CONTAINER_USER:$LXC_CONTAINER_GROUP to host user:group $1"
    lxc_add_uid_gid_map "$LXC_CONTAINER_USER:$LXC_CONTAINER_GROUP:$1"
}

lxc_uid_has_permission() {
    uid="$1"
    file="$2"
    mode="$3" # r, w, or x

    if ! sudo -u "#$uid" /bin/sh -c "[ -${mode} '$file' ]" ; then
        return 1
    fi
}


# ---------------
# File Management
# ---------------

lxc_copy_dir_into_container()
{
    srcdir="$1"
    dstdir="$2"
    pushd "$srcdir"
    tar cf - . | lxc exec $LXC_CONTAINER_NAME -- tar xf - --no-same-owner -C "$dstdir"
    popd

}

lxc_copy_dir_into_container_if_exists()
{
    srcdir="$1"
    dstdir="$2"

    if [ -d "$srcdir" ]; then
        lxc_copy_dir_into_container "$srcdir" "$dstdir"
    fi
}

lxc_copy_fs()
{
    # Copy the "fs" directory into the root of the container
    lxc_copy_dir_into_container_if_exists "$LXC_SOURCE_HOME/fs" /
}

lxc_prepend_file()
{
    file="$1"
    shift
    temp_file="$(lxc_generate_temp_file_name)"
    lxc_exec cp "$file" "$temp_file"
    printf "%s\n" "$@" | lxc_exec tee "$file" >/dev/null
    lxc_exec cat "$temp_file" | lxc_exec tee -a "$file" >/dev/null
    lxc_exec rm -f "$temp_file"
}

lxc_apppend_file()
{
    file="$1"
    shift
    printf "%s" "$@" | lxc_exec tee -a "$file" >/dev/null
}

lxc_write_file()
{
    file="$1"
    shift
    printf "%s" "$@" | lxc_exec tee "$file" >/dev/null
}

lxc_install_packages_alpine()
{
    packages="$@"
    echo "Installing packages $packages"
    lxc_exec apk add $packages
}

lxc_install_packages_ubuntu()
{
    packages="$@"
    echo "Installing packages $packages"
    lxc_exec bash -c "export DEBIAN_FRONTEND=noninteractive; apt install -y $packages"
}

lxc_install_packages()
{
    lxc_install_packages_$LXC_CONTAINER_DISTRIBUTION $@
}


# ----------
# Filesystem
# ----------

lxc_add_to_fstab()
{
    lxc exec $LXC_CONTAINER_NAME -- sh -c "echo \"$1\" >> /etc/fstab"
}

lxc_mount_cifs() {
    # requires cifs-utils
    server="$1"
    share_path="$2"
    mount_point="$3"
    read_write="$4"
    echo "Mounting CIFS $server/$share_path to $mount_point"

    lxc exec $LXC_CONTAINER_NAME -- mkdir -p "$mount_point"
    lxc_add_to_fstab "//$server/$share_path  \"$mount_point\"  cifs  guest,uid=1000,iocharset=utf8  0  0"
    lxc exec $LXC_CONTAINER_NAME -- mount "$mount_point"
}

lxc_mount_nfs() {
    # requires nfs-common
    server="$1"
    share_path="$2"
    mount_point="$3"
    read_write="$4"
    echo "Mounting NFS $server/$share_path to $mount_point"

    lxc exec $LXC_CONTAINER_NAME -- mkdir -p "$mount_point"
    lxc_add_to_fstab "$server:\"$share_path\"  \"$mount_point\"  nfs  rsize=8192,wsize=8192,timeo=14,hard,intr,noexec,nosuid  0  0"
    lxc exec $LXC_CONTAINER_NAME -- mount "$mount_point"
}

lxc_mount_sshfs() {
    user_at_server="$1"
    share_path="$2"
    mount_point="$3"
    read_write="$4"
    echo "Mounting SSH $server/$share_path to $mount_point"

    lxc exec $LXC_CONTAINER_NAME -- mkdir -p "$mount_point"
    lxc_add_to_fstab "$user_at_server:\"$share_path\"  \"$mount_point\"  fuse.sshfs  defaults,_netdev  0  0"
    lxc exec $LXC_CONTAINER_NAME -- mount "$mount_point"
}

lxc_mount_host() {
    device_name="$1"
    host_path="$2"
    mount_point="$3"
    read_write="$4"
    echo "Mounting host $host_path to $mount_point"

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
    # Don't interpret * as a glob.
    set -f
    params=($(get_colon_separated_arguments 5 $1))
    set +f
    if [ ${#params[@]} -ne 5 ]; then
        echo "Invalid mount info format. Must be protocol:server:share_path:mount_point:r_or_w"
        return 1
    fi
    protocol="${params[0]}"
    server="${params[1]}"
    host_path="${params[2]}"
    mount_point="${params[3]}"
    read_write="${params[4]}"

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


# -------
# Network
# -------

lxc_mount_network_bridge()
{
    bridge="$1"
    lxc config device add $LXC_CONTAINER_NAME eth1 nic name=eth1 nictype=bridged parent=$bridge
}

lxc_is_network_up()
{
#   lxc_exec route -n |grep " UG " >/dev/null
#   lxc_exec ip route |grep "default via " >/dev/null
    lxc_exec grep $'\t0003\t' /proc/net/route >/dev/null
}

lxc_wait_for_network()
{
    sleep 1
    until lxc_is_network_up;
    do
        echo "Waiting for network"
        sleep 1
    done
    sleep 2
}

lxc_can_guest_reach_address()
{
    address="$1"
    lxc_exec ping -c 1 -w 15 $address >/dev/null 2>&1
}

lxc_can_host_reach_address()
{
    address="$1"
    ping -c 1 -w 15 $address >/dev/null 2>&1
}


# ----
# Misc
# ----

lxc_mark_privileged()
{
    lxc_set_config security.privileged true
}

lxc_allow_nesting()
{
    # Allows running an LXC container inside another LXC container
    lxc_set_config security.nesting true
}

lxc_allow_kvm()
{
    # KVM needs access to /dev/kvm and /dev/vhost-net
    lxc config device add $LXC_CONTAINER_NAME kvm unix-char path=/dev/kvm
    lxc config device add $LXC_CONTAINER_NAME vhost-net unix-char path=/dev/vhost-net
    lxc config device set $LXC_CONTAINER_NAME vhost-net mode 0600
}

lxc_allow_snap()
{
# TODO: Not needed in 20.04?
#    lxc_mount_host lib-modules "/lib/modules" "/lib/modules" r
echo
}

lxc_fix_unprivileged_dbus()
{
    # Fix to make dbus work correctly on non-privileged containers
    lxc config device add $LXC_CONTAINER_NAME fuse unix-char major=10 minor=229 path=/dev/fuse
}

lxc_set_locale_kb_tz_alpine()
{
    fields=($(get_colon_separated_arguments 5 $1))
    language="${fields[0]}"
    region="${fields[1]}"
    kb_layout="${fields[2]}"
    kb_model="${fields[3]}"
    timezone="${fields[4]}"

    lxc_install_packages tzdata
    lxc_exec ln -s /usr/share/zoneinfo/$timezone /etc/localtime
    lxc_write_file /etc/timezone $timezone
}

lxc_set_locale_kb_tz_ubuntu()
{
    fields=($(get_colon_separated_arguments 5 $1))
    language="${fields[0]}"
    region="${fields[1]}"
    kb_layout="${fields[2]}"
    kb_model="${fields[3]}"
    timezone="${fields[4]}"

    lxc_install_packages locales tzdata debconf software-properties-common

    lang_base="${language}_${region}"
    lang_full="${lang_base}.UTF-8"

    lxc_exec locale-gen ${lang_base} ${lang_full}
    lxc_exec update-locale LANG=${lang_full} LANGUAGE=${lang_base}:${language} LC_ALL=${lang_full}
    echo "keyboard-configuration keyboard-configuration/layoutcode string ${kb_layout}" | lxc_exec debconf-set-selections
    echo "keyboard-configuration keyboard-configuration/modelcode string ${kb_model}" | lxc_exec debconf-set-selections

    lxc_exec timedatectl set-timezone "$timezone"
}

lxc_set_locale_kb_tz()
{
    # Example: en:US:us:pc105:America/Vancouver
    lxc_set_locale_kb_tz_$LXC_CONTAINER_DISTRIBUTION $@
}

lxc_run_installer_script()
{
    echo "Running installer script"
    lxc_run_script "$LXC_SOURCE_HOME/installer.sh" $@
    echo "Installer script completed successfully. Container is running at $(lxc_get_default_ip_address)"
}
