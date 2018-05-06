MOUNT_PATHS=$@

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
    path=$1
    machine=$2
    readwrite=$(get_readwrite $3)
    exports="/etc/exports"
    echo "$path $machine($readwrite,all_squash,no_subtree_check)" >> $exports
}

fix_repositories
install_packages nfs-utils

for i in $MOUNT_PATHS; do
    path=$(echo $i|sed 's/\([^:]*\):.*/\1/g')
    machine=$(echo $i|sed 's/[^:]*:\([^:]*\):.*/\1/g')
    readwrite=$(echo $i|sed 's/[^:]*:[^:]*:\([^:]*\).*/\1/g')
    mount_share $path $machine $readwrite
done

activate_services nfs
