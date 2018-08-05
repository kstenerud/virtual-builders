INCLUDED_SH=INCLUDED_580c5d418d224ac6bf5ce7c58d1f5fae; if [ ! -z ${!INCLUDED_SH} ]; then return 0; fi; eval ${INCLUDED_SH}=true

fix_repositories()
{
    install_packages wget
}

create_user()
{
    username=$1
    password=$2
    echo "Creating user $username"
    useradd --create-home --shell /bin/bash --user-group --groups adm,sudo $username
    echo ${username}:${password} | chpasswd
}

create_nologin_user()
{
    username=$1
    echo "Creating nologin user $username"
    useradd --shell /usr/sbin/nologin --user-group --groups $username
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
    for repo in $repositories; do
        add-apt-repository -y $repo
    done
    apt update
}

synchronize_packages()
{
    echo "Synchronizing packages"
    bash -c "(export DEBIAN_FRONTEND=noninteractive; apt install -y)"
}

install_packages()
{
    packages=$@
    echo "Installing packages $packages"
    bash -c "(export DEBIAN_FRONTEND=noninteractive; apt install -y $packages)"
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
        install_packages "$tmpfile"
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
        systemctl enable $service
        systemctl start $service
    done
}

disable_services()
{
    service_names=$@
    for service in $service_names; do
        echo "Disabling service $service"
        systemctl disable $service
    done
}