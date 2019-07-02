set -eu

USERNAME="$1"
PASSWORD="$2"
CRD_RESOLUTION="$3"

# Do this early to avoid uid/gid brokenness when mapping outside container
create_user $USERNAME "$PASSWORD"

remove_packages cloud-init
install_packages git
cd /tmp
git clone --recurse-submodules -j8 https://github.com/kstenerud/work-installer.git
./work-installer/install-virtual-desktop.sh -r $CRD_RESOLUTION -u $USERNAME 
./work-installer/install-dev-software.sh
./work-installer/install-gui-software.sh
./work-installer/add-to-groups.sh $USERNAME
rm -rf work-installer
