#!/bin/bash

if [ ${#@} -lt 1 ]; then
	echo "Turns on autoboot for an LXC container."
	echo
	echo "Usage: $0 <lxc container name>"
    exit 1
fi

set -eu

CONTAINER_NAME="$1"

lxc config set $CONTAINER_NAME boot.autostart 1

