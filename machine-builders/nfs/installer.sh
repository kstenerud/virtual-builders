MOUNT_PATHS="$@"

get_readwrite() {
    case "$1" in
        r) echo ro ;;
        w) echo rw ;;
        *)
            >&2 echo "$1: Unknown read/write flag"
            exit 1
    esac
}

mount_share() {
    path="$1"
    machine="$2"
    readwrite="$(get_readwrite $3)"
    exports="/etc/exports"
    echo "$path $machine($readwrite,all_squash,no_subtree_check)" >> $exports
}

fix_repositories
install_packages nfs-utils

for i in $MOUNT_PATHS; do
    set -- $(get_colon_separated_arguments 3 $i)
    path="$1"
    machine="$2"
    readwrite="$3"

    mount_share $path $machine $readwrite
done

activate_services nfs
