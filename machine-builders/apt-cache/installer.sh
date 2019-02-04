set -eu

install_packages apt-cache-ng

service apt-cacher-ng restart
