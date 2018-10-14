MOUNT_PATHS="$@"

delete_user ubuntu
useradd -U -d /var/lib/plexmediaserver -s /usr/sbin/nologin plex
usermod -G users plex

fix_repositories
install_packages net-tools tzdata curl xmlstarlet uuid-runtime unrar
install_packages_from_urls "$(curl -s "https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=16&distro=ubuntu" | sed -n 's/.*url="\([^"]*\)".*/\1/p')"
