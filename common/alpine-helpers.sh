INCLUDED_SH=INCLUDED_ade3d2aaae3b4dd780d024b2a6010c3b; if [ ! -z ${!INCLUDED_SH} ]; then return 0; fi; eval ${INCLUDED_SH}=true

fix_repositories()
{
    add_repositories "http://dl-4.alpinelinux.org/alpine/v3.7/main" \
                     "http://dl-4.alpinelinux.org/alpine/v3.7/community"
}

create_user()
{
    username=$1
    password=$2
    echo "Creating user $username"
    useradd --create-home --shell /bin/sh --user-group --groups adm,sudo $username
    echo ${username}:${password} | chpasswd
}

delete_user()
{
    username=$1
    echo "Deleting user $username"
    userdel -r $username
}

add_repositories()
{
    repositories=$@
    echo "Adding repositories $repositories"
    for url in $repositories; do
        echo "$url" >> /etc/apk/repositories
    done
}

synchronize_packages()
{
    apk add
}

install_packages()
{
    packages=$@
    echo "Installing packages $packages"
    apk add $packages
}

install_packages_from_repository()
{
    repo=$1
    shift
    packages=$@
    add_repositories $repo
    install_packages $packages
}

install_packages_from_urls()
{
    urls=$@
    echo "Installing packages from $urls"
    for url in $urls; do
        tmpfile="/tmp/tmp_deb_pkg_$(basename $url)"
        wget -qO $tmpfile "$url"
        apk add --allow-untrusted "$tmpfile"
        rm "$tmpfile"
    done
}

install_script_from_url()
{
    url=$1
    shift
    arguments=$@
    echo "Installing from script at $url with args $arguments"
    tmpfile="/tmp/tmp_install_script_$(basename $url)"
    wget -qO $tmpfile "$url"
    chmod a+x "$tmpfile"
    $tmpfile $arguments
    rm "$tmpfile"
}

activate_services()
{
    service_names=$@
    for service in $service_names; do
        echo "Activating service $service"
        rc-update add $service
        rc-service $service start
    done
}
