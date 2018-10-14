INCLUDED_SH=INCLUDED_580c5d418d224ac6bf5ce7c58d1f5fae; if [ ! -z ${!INCLUDED_SH} ]; then return 0; fi; eval ${INCLUDED_SH}=true

fix_repositories()
{
    install_packages wget
}

create_user()
{
    username="$1"
    password="$2"
    echo "Creating user $username"
    useradd --create-home --shell /bin/bash --user-group --groups adm,sudo $username
    echo ${username}:${password} | chpasswd
}

create_nologin_user()
{
    username="$1"
    echo "Creating nologin user $username"
    useradd --shell /usr/sbin/nologin --user-group --groups $username
}

delete_user()
{
    username="$1"
    echo "Deleting user $username"
    userdel -r $username
}

add_repositories()
{
    repositories="$@"
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
    packages="$@"
    echo "Installing packages $packages"
    bash -c "(export DEBIAN_FRONTEND=noninteractive; apt install -y $packages)"
}

remove_packages()
{
    packages="$@"
    echo "Removing packages $packages"
    apt remove -y $packages
}

sanitize_filename()
{
    filename="$(basename "$1" | tr -cd 'A-Za-z0-9_.')"
    echo "$filename"
}

install_packages_from_repository()
{
    repo="$1"
    shift
    packages="$@"
    add_repositories $repo
    install_packages $packages
}

install_packages_from_urls()
{
    urls="$@"
    echo "Installing packages from $urls"
    for url in $urls; do
        tmpfile="/tmp/tmp_deb_pkg_$(sanitize_filename $url).deb"
        wget -qO $tmpfile "$url"
        install_packages "$tmpfile"
        rm "$tmpfile"
    done
}

install_script_from_url()
{
    url="$1"
    shift
    arguments="$@"
    echo "Installing from script at $url with args $arguments"
    tmpfile="/tmp/tmp_install_script_$(sanitize_filename $url)"
    wget -qO $tmpfile "$url"
    chmod a+x "$tmpfile"
    $tmpfile $arguments
    rm "$tmpfile"
}

install_snap()
{
    snap="$1"
    mode="$2"
    snap install --$mode $snap
}

install_snaps()
{
    snaps="$@"
    for snap in $snaps; do
        snap install $snap
    done
}

install_classic_snaps()
{
    snaps="$@"
    for snap in $snaps; do
        snap install $snap --classic
    done
}

activate_services()
{
    service_names="$@"
    for service in $service_names; do
        echo "Activating service $service"
        systemctl enable $service
        systemctl start $service
    done
}

disable_services()
{
    service_names="$@"
    for service in $service_names; do
        echo "Disabling service $service"
        set +e
        systemctl disable $service
        set -e
    done
}

apply_bluetooth_fix()
{
    # Force bluetooth to install and then disable it so that it doesn't break the rest of the install.
    set +e
    apt install -y bluez
    set -e
    systemctl disable bluetooth
    apt install -y
}

crd_enable_high_resolution()
{
    sed -i 's/DEFAULT_SIZE_NO_RANDR = "1600x1200"/DEFAULT_SIZE_NO_RANDR = "4096x2160"/g' /opt/google/chrome-remote-desktop/chrome-remote-desktop
}
