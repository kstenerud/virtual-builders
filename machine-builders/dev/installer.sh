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
remove_packages cloud-init
create_user $USERNAME $PASSWORD
install_desktop
install_remote_desktop $CRD_RESOLUTION
install_other_software
disable_unneeded_services
