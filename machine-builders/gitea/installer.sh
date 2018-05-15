adduser -h /var/lib/gitea -s /sbin/nologin -D -u 1000 gitea gitea

fix_repositories
install_packages gitea
activate_services gitea
