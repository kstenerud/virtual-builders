fix_repositories
install_packages nginx fgallery

rm -rf /var/www/html
fgallery -t /var/photos /var/www/html
