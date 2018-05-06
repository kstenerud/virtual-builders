#!/bin/bash

# KMS Server Builder
#
# Spins up a dev environment, builds vlmcs and vlmcsd, and copies them inside fs/usr/sbin.
#
# See build-fs/root/install_vlmcsd.sh for more details.

set -eu

SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

CONTAINER_NAME=vlmcsd-builder
GIT_REPO=https://github.com/kstenerud/vlmcsd.git

lxc launch images:alpine/3.7 $CONTAINER_NAME
sleep 1

# Overlay
pushd "$SCRIPT_HOME/build-fs"
tar cf - . | lxc exec $CONTAINER_NAME -- tar xf - -C /
popd

lxc exec $CONTAINER_NAME -- /root/install_vlmcsd.sh $GIT_REPO

lxc file pull vlmcsd-builder/root/vlmcsd/bin/vlmcs "$SCRIPT_HOME/fs/usr/sbin/"
lxc file pull vlmcsd-builder/root/vlmcsd/bin/vlmcsd "$SCRIPT_HOME/fs/usr/sbin/"

lxc delete --force $CONTAINER_NAME
