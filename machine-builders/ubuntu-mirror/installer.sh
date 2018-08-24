set -eu

RELEASE=$1

install_packages apt-mirror python3

cat /etc/apt/mirror.list.template |sed -e "s/UBUNTURELEASE/$RELEASE/g" > /etc/apt/mirror.list

activate_services ubuntu-mirror
