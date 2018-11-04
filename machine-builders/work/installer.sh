set -eu

USERNAME="$1"
PASSWORD="$2"
CRD_RESOLUTION="$3"

# Do this early to avoid uid/gid brokenness when mapping outside container
create_user $USERNAME "$PASSWORD"

remove_packages cloud-init
install_packages git
cd /tmp
git clone https://github.com/kstenerud/ubuntu-dev-installer.git
./ubuntu-dev-installer/install-guest.sh -d -r $CRD_RESOLUTION -u $USERNAME
rm -rf ubuntu-dev-installer
