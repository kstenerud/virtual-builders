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
        flex \
        gdb \
        git \
        gvfs-bin \
        libtool \
        libvirt-bin \
        lxd \
        meld \
        meson \
        mtools \
        nasm \
        ninja-build \
        nmap \
        net-tools \
        nfs-common \
        ovmf \
        pkg-config \
        python3-pip \
        python3-pytest \
        qemu \
        qemu-kvm \
        remmina \
        remmina-plugin-nx \
        remmina-plugin-spice \
        rsnapshot \
        telnet \
        ubuntu-dev-tools \
        uvtool \
        virt-manager \
        virtinst

    install_classic_snaps \
        sublime-text

    install_packages_from_urls \
        https://go.microsoft.com/fwlink/?LinkID=760868 \
        https://release.gitkraken.com/linux/gitkraken-amd64.deb

    install_packages_from_repository ppa:gophers/archive golang-go

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
