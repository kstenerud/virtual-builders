#!/bin/bash

set -eu

SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
LXC_SOURCE_HOME="$SCRIPT_HOME"
source $SCRIPT_HOME/../common/lxc-helpers.sh
source $SCRIPT_HOME/../common/options.sh

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options]"
options_set_help_flag_and_description H "Create a Linux desktop container."
options_add_switch b bridge   "The bridge to connect to"             required br0
options_add_switch m path     "Path to mount as the user's home dir" required
options_add_switch n name     "The container's name"                 required crd
options_add_switch p password "Password to assign to the user"       required ubuntu
options_add_switch u name     "Name of user to create"               required ubuntu
options_add_flag   P          "Create a privileged container"        optional
options_read_arguments $@

CONTAINER_DISTRO=ubuntu
CONTAINER_NAME=$(options_get_value n)
USERNAME=$(options_get_value u)
PASSWORD=$(options_get_value p)
HOME_MOUNT=$(options_get_value m)
BRIDGE=$(options_get_value b)
IS_PRIVILEGED=$(options_get_value P)
DESKTOP_TYPE=$(options_get_value d)

lxc_build_standard_container $CONTAINER_DISTRO $CONTAINER_NAME
if [ $IS_PRIVILEGED == "true" ]; then
	lxc_mark_privileged
else
	lxc_fix_unprivileged_dbus
fi
lxc restart $CONTAINER_NAME

lxc_mount_path home "$HOME_MOUNT" "/home/$USERNAME"

lxc_run_installer_script $USERNAME $PASSWORD $IS_PRIVILEGED
