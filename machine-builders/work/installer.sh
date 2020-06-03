set -eu

USERNAME="$1"
PASSWORD="$2"

# Do this early to avoid uid/gid brokenness when mapping outside container
create_user $USERNAME "$PASSWORD"

remove_packages cloud-init
install_packages git
cd /tmp
git clone --recurse-submodules -j8 https://github.com/kstenerud/work-installer.git
./work-installer/install-dev-software.sh
./work-installer/add-to-groups.sh $USERNAME
./work-installer/install-hostmanager.sh
rm -rf work-installer
sudo apt install -y openvpn network-manager-openvpn
