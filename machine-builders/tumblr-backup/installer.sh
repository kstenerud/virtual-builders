adduser -h /home/tumblr -s /sbin/nologin -D -u 1000 tumblr tumblr

fix_repositories
install_packages bash git openssh python

cd /home/tumblr
git clone https://github.com/kstenerud/tumblr_backup.git
cd tumblr_backup
git submodule update --init --recursive
cd ..
mv tumblr_backup/* .
rm -rf tumblr_backup
chown tumblr:tumblr *
chown -R tumblr:tumblr tumblr-utils
(crontab -l 2>/dev/null; echo "25	1	*	*	*	/home/tumblr/backup.sh >> /home/tumblr/backup.log 2>&1") | crontab -u tumblr -
