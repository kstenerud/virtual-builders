set -eu

EMAIL_ADDRESS=$1

adduser -h /home/gmail -s /sbin/nologin -D -u 1000 gmail gmail
chmod 755 /

fix_repositories
install_packages bash py-pip

cd /home/gmail
pip install gmvault
(crontab -l 2>/dev/null; echo "55	1	*	*	*	gmvault sync -t quick $EMAIL_ADDRESS >> /home/gmail/backup.log 2>&1") | crontab -u gmail -
