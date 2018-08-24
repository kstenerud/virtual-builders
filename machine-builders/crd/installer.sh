set -eu

DESKTOP_TYPE=mate
USERNAME=$1
PASSWORD=$2
IS_PRIVILEGED=$3

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
}

install_other_software() {
    install_packages \
        remmina \
        telnet
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

# apply_dns_fix
apply_bluetooth_fix
create_user
install_desktop
install_remote_desktop
install_other_software
disable_unneeded_services
