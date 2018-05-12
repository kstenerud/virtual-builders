MOUNT_PATHS=$@

delete_user ubuntu
useradd -U -d /plexconfig -s /bin/false plex
usermod -G users plex

fix_repositories
install_packages net-tools tzdata curl xmlstarlet uuid-runtime unrar
install_packages_from_urls "$(curl -s "https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=16&distro=ubuntu" | sed -n 's/.*url="\([^"]*\)".*/\1/p')"

echo "export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/var/lib/plexmediaserver/config" >>/etc/default/plexmediaserver

# apt-get -y autoremove && \
# apt-get -y clean && \
# rm -rf /var/lib/apt/lists/* && \
# rm -rf /tmp/* && \
# rm -rf /var/tmp/*

# useradd -U -d /config -s /bin/false plex
# usermod -G users plex

# mkdir -p /config /transcode /data


# EXPOSE 32400/tcp 3005/tcp 8324/tcp 32469/tcp 1900/udp 32410/udp 32412/udp 32413/udp 32414/udp
# VOLUME /config /transcode

# ENV CHANGE_CONFIG_DIR_OWNERSHIP="true" \
#     HOME="/config"

# ARG TAG=beta
# ARG URL=

# /var/lib/plexmediaserver/Library/Application Support/Plex Media Server
