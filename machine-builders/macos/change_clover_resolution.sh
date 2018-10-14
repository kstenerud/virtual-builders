#!/bin/bash

# Change the screen resolution settings inside a Clover.qcow2 image.
# Note: This script must be run as root!

ALLOWED_RESOLUTIONS=( 640x480 800x480 800x600 832x624 960x640 1024x600 1024x768 1152x864 1152x870 1280x720 12
80x768 1280x800 1280x960 1280x1024 1360x768 1366x768 1400x1050 1400x900 1600x900 1600x1200 1680x1050 1920x108
0 1920x1200 1920x1440 2000x2000 2048x1536 2048x2048 2560x1440 2560x1600 )

function set_resolution {
	clover_image="$1"
    resolution="$2"
    mount_point="/tmp/clover_mount"
    config_plist="$mount_point/EFI/CLOVER/config.plist"

    mkdir -p "$mount_point"
    guestmount -a "$clover_image" -m /dev/sda1 "$mount_point"
    sed -i "s/>[0-9][0-9][0-9]*x[0-9][0-9][0-9]*</>$resolution</g" "$config_plist"
    umount "$mount_point"
    sleep 1s
    rmdir "$mount_point"
}

function is_valid_resolution {
    resolution="$1"
    for i in "${ALLOWED_RESOLUTIONS[@]}"; do
        if [ "$i" == "$resolution" ]; then
            echo "true"
            return 0
        fi
    done

    echo "false"
}

function list_resolutions {
    echo "Allowed resolutions:"
    echo ${ALLOWED_RESOLUTIONS[*]}
}


if [ ${#@} -lt 2 ]; then
	echo "Usage: $0 <path to clover image> <screen resolution>"
	echo
    list_resolutions
    exit 1
fi

set -eu

CLOVER_IMAGE="$1"
SCREEN_RESOLUTION="$2"

if [ $(is_valid_resolution "$SCREEN_RESOLUTION") != "true" ]; then
    echo "$SCREEN_RESOLUTION is not a valid resolution."
    list_resolutions
    exit 1
fi


set_resolution "$CLOVER_IMAGE" $SCREEN_RESOLUTION
