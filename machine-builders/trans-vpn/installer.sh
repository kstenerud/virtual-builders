set -eu

install_packages transmission-daemon

service transmission-daemon stop
sed -i 's/"rpc-whitelist": "127.0.0.1"/"rpc-whitelist": "127.0.0.1,192.168.111.*"/g' /etc/transmission-daemon/settings.json
service transmission-daemon start

install_packages_from_urls https://s3.amazonaws.com/purevpn-dialer-assets/linux/app/purevpn_1.2.3_amd64.deb
systemctl enable purevpn-nl
systemctl start purevpn-nl

echo
echo "==========================="
echo "Remember to purevpn --login"
echo "==========================="
echo

