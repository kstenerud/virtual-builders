set -eu

DESKTOP_TYPE=mate
USERNAME="$1"
PASSWORD="$2"
CRD_RESOLUTION="$3"

install_desktop() {
    install_packages software-properties-common ubuntu-mate-desktop
    apt remove -y light-locker
}

install_other_software() {
    install_packages \
        nmap \
        remmina \
        transmission \
        filezilla \
        nfs-common \
        telnet \
        vlc
}

mkdir /tmp/amule
pushd /tmp/amule
wget http://archive.ubuntu.com/ubuntu/pool/universe/a/amule/amule_2.3.2-6_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/universe/a/amule/amule-common_2.3.2-6_all.deb
wget http://archive.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxgtk3.0-0v5_3.0.4+dfsg-12_amd64.deb
apt install -y ./*.deb
popd

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
