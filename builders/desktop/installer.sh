set -eu

DESKTOP_TYPE=$1
USERNAME=$2
PASSWORD=$3
IS_PRIVILEGED=$4

declare -A DESKTOPS
declare -a DESKTOP_KEYS
function add_desktop {
    DESKTOPS[$1]=$2
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

apply_dns_fix()
{
    echo "8.8.8.8" >/etc/resolv.conf
}

apply_bluetooth_fix()
{
	# Force bluetooth to install and then disable it so that it doesn't break the rest of the install.
	set +e
	apt install -y bluez
	set -e
	systemctl disable bluetooth
	apt install -y
}

create_user()
{
	if [ $USERNAME != ubuntu ]; then
		userdel -r ubuntu
	    useradd --create-home --shell /bin/bash --user-group --groups adm,sudo $USERNAME
	    echo "$USERNAME:$PASSWORD" | chpasswd
	fi
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
}

install_other_software() {
    install_packages \
        amule \
        gedit \
        openvpn \
        telnet \
        transmission \
        filezilla
}

install_dev_software() {
    install_packages \
        autoconf \
        bison \
        build-essential \
        flex \
        geany \
        gettext \
        git \
        gradle \
        gvfs-bin \
        libfuse-dev \
        libglu1-mesa \
        libjpeg-dev \
        libpam0g-dev \
        libssl-dev \
        libtool \
        libx11-dev \
        libxfixes-dev \
        libxml-parser-perl \
        libxrandr-dev \ \
        meld \
        mono-complete \
        nasm \
        pkg-config \
        protobuf-compiler \
        python-libxml2 \
        python-pip \
        thrift-compiler \
        visualvm \
        xfonts-scalable \
        xinput \
        xorg \
        xserver-xorg-dev \
        xsltproc

    # install_packages_from_repo ppa:webupd8team/sublime-text-3 sublime-text
    # install_deb_from_http https://go.microsoft.com/fwlink/?LinkID=760868 vscode.deb
    install_packages_from_urls https://release.gitkraken.com/linux/gitkraken-amd64.deb
    install_packages_from_repository ppa:gophers/archive golang-1.10-go
    install_script_from_url https://sh.rustup.rs -y
}

sleep 2
# apply_dns_fix
apply_bluetooth_fix
create_user
install_desktop
install_remote_desktop
install_other_software
install_dev_software
