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

get_homedir()
{
    username=$1
    eval echo "~$username"
}

chown_homedir()
{
    username=$1

    chown -R $username:$(id -g $username) "$(get_homedir $username)"
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
    echo "Installing from $repo: $packages"
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
    echo "Installing snap $snap using mode $mode"
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
        systemctl disable $service || true
    done
}

apply_bluetooth_fix()
{
    # Force bluetooth to install and then disable it so that it doesn't break the rest of the install.
    apt install -y bluez || true
    systemctl disable bluetooth
    apt install -y
}

crd_set_resolution()
{
    resolution=$1
    echo "Setting Chrome Remote Desktop resolution to $resolution"
    sed_command="s/DEFAULT_SIZE_NO_RANDR = \"1600x1200\"/DEFAULT_SIZE_NO_RANDR = \"$resolution\"/g"
    sed -i "$sed_command" /opt/google/chrome-remote-desktop/chrome-remote-desktop
}

install_remote_desktop() {
    resolution=$1
    # TODO: Not available for 20.04 yet
    # install_packages_from_repository ppa:x2go/stable x2goserver x2goserver-xsession x2goclient
    install_packages_from_urls https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
                               https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
    crd_set_resolution $resolution
}

set_user_password()
{
    username=$1
    password="$2"

    echo "$username:$password" | chpasswd
}

create_user()
{
    username=$1
    password="$2"
    echo "Creating user $username"
    if [ $username != ubuntu ]; then
        userdel -r ubuntu
        useradd --create-home --shell /bin/bash --user-group --groups adm,sudo $username
    fi

    set_user_password $username "$password"
    chown_homedir $username
}
