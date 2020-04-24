set -eu

USERNAME="$1"
PASSWORD="$2"

install_console_software()
{
    install_snaps \
        docker

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
        docker-compose \
        dpkg-dev \
        flex \
        fuse \
        git \
        git-buildpackage \
        libvirt-bin \
        mtools \
        nmap \
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
        squashfuse \
        ubuntu-dev-tools \
        virtinst
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
disable_unneeded_services
