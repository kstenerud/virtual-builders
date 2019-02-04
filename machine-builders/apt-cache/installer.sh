set -eu

RELEASE="$1"

install_packages apt-cache-ng

service apt-cacher-ng restart
