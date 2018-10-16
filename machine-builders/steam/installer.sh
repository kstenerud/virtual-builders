set -eu

USERNAME="$1"
PASSWORD="$2"
CRD_RESOLUTION="$3"

install_desktop() {
    install_packages software-properties-common ubuntu-mate-desktop
    apt remove -y light-locker
}

install_other_software() {
    install_packages \
        filezilla \
        remmina \
        telnet \
        wine32 \
        wine-stable
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

download_steam()
{
    mkdir -p /home/$USERNAME/Downloads
    pushd /home/$USERNAME/Downloads
    wget https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe
    popd
}

install_steam_scripts()
{
    mkdir -p /home/$USERNAME/bin
    echo "wine ~/.wine/drive_c/Program\ Files\ \(x86\)/Steam/Steam.exe" >/home/$USERNAME/bin/steam.sh
}

apply_bluetooth_fix
remove_packages cloud-init
dpkg --add-architecture i386 && apt update
create_user $USERNAME $PASSWORD
install_desktop
install_remote_desktop $CRD_RESOLUTION
install_other_software
disable_unneeded_services
download_steam
install_steam_scripts
