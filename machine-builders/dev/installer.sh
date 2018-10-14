set -eu

DESKTOP_TYPE=mate
USERNAME="$1"
PASSWORD="$2"
IS_PRIVILEGED="$3"

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
    install_packages software-properties-common ubuntu-mate-desktop
    apt remove -y light-locker
}

install_remote_desktop() {
    install_packages_from_repository ppa:x2go/stable x2goserver x2goserver-xsession x2goclient
    install_packages_from_urls https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
                               https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
    crd_enable_high_resolution
}

install_other_software() {
    install_packages \
        autoconf \
        autopkgtest \
        bison \
        bridge-utils \
        build-essential \
        cmake \
        cpu-checker \
        curl \
        debconf-utils \
        devscripts \
        docker.io \
        dpkg-dev \
        flex \
        gradle \
        git \
        git-buildpackage \
        gvfs-bin \
        libtool \
        libvirt-bin \
        lxd \
        meld \
        mono-complete \
        mtools \
        nasm \
        net-tools \
        nfs-common \
        ovmf \
        pkg-config \
        python-pip \
        python3-argcomplete \
        python3-lazr.restfulclient \
        python3-debian \
        python3-distro-info \
        python3-launchpadlib \
        python3-pygit2 \
        python3-ubuntutools \
        python3-pkg-resources \
        python3-pytest \
        python3-petname \
        qemu \
        qemu-kvm \
        quilt \
        remmina \
        rsnapshot \
        telnet \
        ubuntu-dev-tools \
        uvtool \
        virt-manager \
        virtinst

    install_classic_snaps \
        git-ubuntu \
        sublime-text \
        ustriage

    install_packages_from_urls \
        https://go.microsoft.com/fwlink/?LinkID=760868 \
        https://release.gitkraken.com/linux/gitkraken-amd64.deb

    install_packages_from_repository ppa:gophers/archive golang-1.10-go

    install_script_from_url https://sh.rustup.rs -y
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
