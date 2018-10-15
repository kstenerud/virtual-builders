set -eu

DESKTOP_TYPE="$1"
USERNAME="$2"
PASSWORD="$3"
CRD_RESOLUTION="$4"

declare -A DESKTOPS
declare -a DESKTOP_KEYS
function add_desktop {
    DESKTOPS[$1]="$2"
    DESKTOP_KEYS+=( $1 )
}
add_desktop budgie   "ubuntu-budgie-desktop gnome-settings-daemon gnome-session"
add_desktop cinnamon cinnamon-desktop-environment
add_desktop gnome    ubuntu-gnome-desktop
add_desktop kde      kubuntu-desktop
add_desktop lxde     lubuntu-desktop
add_desktop mate     ubuntu-mate-desktop
add_desktop ubuntu   ubuntu-desktop
add_desktop unity    ubuntu-unity-desktop
add_desktop xfce     xubuntu-desktop
add_desktop all      ${DESKTOPS[*]}

install_desktop() {
    install_packages software-properties-common ${DESKTOPS[$DESKTOP_TYPE]}
    apt remove -y light-locker
}

install_other_software() {
    install_packages \
        nfs-common \
        telnet \
        filezilla
}
disable_unneeded_services() {
    disable_services \
        apport \
        cpufrequtils \
        hddtemp \
        lm-sensors \
        network-manager \
        speech-dispatcher \
        ufw \
        unattended-upgrades
}

apply_bluetooth_fix
remove_packages cloud-init
create_user $USERNAME $PASSWORD
install_desktop
install_remote_desktop $CRD_RESOLUTION
install_other_software
disable_unneeded_services
