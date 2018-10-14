set -eu

DESKTOP_TYPE="$1"
USERNAME="$2"
PASSWORD="$3"
IS_PRIVILEGED="$4"

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

create_user()
{
	if [ $USERNAME != ubuntu ]; then
		userdel -r ubuntu
	    useradd --create-home --shell /bin/bash --user-group --groups adm,sudo $USERNAME
	fi
    echo "$USERNAME:$PASSWORD" | chpasswd
    if [ "$IS_PRIVILEGED" == "true" ]; then
        chown $USERNAME:$USERNAME /home/$USERNAME
    fi
}

install_desktop() {
    install_packages software-properties-common ${DESKTOPS[$DESKTOP_TYPE]}
    apt remove -y light-locker
}

install_remote_desktop() {
    install_packages_from_repository ppa:x2go/stable x2goserver x2goserver-xsession
    install_packages_from_urls https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
                               https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
    crd_enable_high_resolution
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
create_user
install_desktop
install_remote_desktop
install_other_software
disable_unneeded_services
