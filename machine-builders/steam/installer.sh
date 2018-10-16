set -eu

USERNAME="$1"
PASSWORD="$2"
CRD_RESOLUTION="$3"

install_desktop() {
    install_packages software-properties-common ubuntu-mate-desktop
    apt remove -y light-locker
}

install_other_software() {
    dpkg --add-architecture i386 && apt update
    install_packages \
        nmap \
        filezilla \
        remmina \
        telnet \
        wine32 \
        wine64 \
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

add_bin_path()
{
    echo "PATH=\"\$HOME/bin:\$PATH\"" >> /home/$USERNAME/.profile
}

install_steam_scripts()
{
    WINEPREFIX="WINEARCH=win64"
    mkdir -p /home/$USERNAME/bin
    echo "$WINEPREFIX wine ~/.wine/drive_c/Program\ Files\ \(x86\)/Steam/Steam.exe" >/home/$USERNAME/bin/steam.sh
    chmod a+x /home/$USERNAME/bin/steam.sh
    echo "$WINEPREFIX winecfg && $WINEPREFIX wine ~/Downloads/SteamSetup.exe" >/home/$USERNAME/Downloads/steamsetup.sh
    chmod a+x /home/$USERNAME/Downloads/steamsetup.sh
    echo "-dx10" >/home/$USERNAME/Downloads/kf2_add_to_launch_options.txt
}

apply_bluetooth_fix
remove_packages cloud-init
create_user $USERNAME $PASSWORD
install_desktop
install_remote_desktop $CRD_RESOLUTION
install_other_software
disable_unneeded_services
download_steam
install_steam_scripts
add_bin_path
chown -R $USERNAME:$USERNAME /home/$USERNAME
