set -eu

RELEASE=$1

sleep 2
install_packages apt-mirror

cat /etc/apt/mirror.list.template |sed -e "s/UBUNTURELEASE/$RELEASE/g" > /etc/apt/mirror.list
