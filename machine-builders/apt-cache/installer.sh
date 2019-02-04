set -eu

install_packages apt-cacher-ng avahi-daemon

service apt-cacher-ng restart
