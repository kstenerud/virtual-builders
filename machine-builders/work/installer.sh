set -eu

USERNAME="$1"
PASSWORD="$2"
CRD_RESOLUTION="$3"

install_desktop() {
    install_packages software-properties-common ubuntu-mate-desktop
    remove_packages light-locker
}

install_console_software()
{
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
        fuse \
        git \
        git-buildpackage \
        libvirt-bin \
        lxd \
        mtools \
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
        rsnapshot \
        snapcraft \
        snapd \
        squashfuse \
        ubuntu-dev-tools \
        uvtool

    install_classic_snaps \
        git-ubuntu \
        ustriage
}

install_gui_software() {
    echo "wireshark-common  wireshark-common/install-setuid boolean true" | debconf-set-selections

    install_packages \
        filezilla \
        hexchat \
        meld \
        virt-manager \
        virtinst \
        wireshark

    install_snaps \
        telegram-desktop

    install_classic_snaps \
        sublime-text
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
install_console_software
install_desktop
install_remote_desktop $CRD_RESOLUTION
install_gui_software
disable_unneeded_services
