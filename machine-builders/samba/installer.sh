MOUNT_PATHS=$@

get_writable() {
    case "$1" in
        r) echo no ;;
        w) echo yes ;;
        *)
            >&2 echo "$1: Unknown read/write flag"
            exit 1
    esac
}

mount_share() {
    path=$1
    name=$2
    writable=$(get_writable $3)
    echo "Mounting $path as $name (writable=$writable)"
    smbconf="/etc/samba/smb.conf"
    echo "" >> $smbconf
    echo "[$name]" >> $smbconf
    echo "    path = $path" >> $smbconf
    echo "    writable = $writable" >> $smbconf
    echo "    browsable = yes" >> $smbconf
    echo "    guest ok = yes" >> $smbconf
}

fix_avahi()
{
    sed -i 's/\(rlimit-nproc\)/#\1/g' /etc/avahi/avahi-daemon.conf
    sed -i 's/#enable-dbus=yes/enable-dbus=no/g' /etc/avahi/avahi-daemon.conf
    sed -i 's/need dbus/use dbus/g' /etc/init.d/avahi-daemon
    rm /etc/avahi/services/ssh.service /etc/avahi/services/sftp-ssh.service
}

set_netbios_name()
{
    hostname=$(cat /etc/hostname)
    sed -i "s/PLACEHOLDER_NETBIOS_NAME/$hostname/g" /etc/samba/smb.conf
}

fix_repositories
install_packages samba avahi
fix_avahi
set_netbios_name

for i in ${MOUNT_PATHS}; do
    set -- $(get_colon_separated_arguments 3 $i)
    path=$1
    name=$2
    readwrite=$3

    mount_share $path $name $readwrite
done

activate_services samba avahi-daemon
