adduser -h /var/lib/transmission -s /sbin/nologin -D -u 1000 transmission transmission

mkdir -p /var/lib/transmission/downloads
chown transmission:transmission /var/lib/transmission/downloads

fix_repositories
install_packages transmission-daemon
activate_services transmission-daemon


# Settings to change
# "download-queue-size": 5,
# "peer-port": 51413,
# "ratio-limit": 2,
# "ratio-limit-enabled": false,
# "rpc-authentication-required": false,
# "rpc-username": "",
# "rpc-password": "{4e318cae37ff958b0d268c70ba7fc56144819514hELHCu3p",
# "rpc-whitelist-enabled": true,
