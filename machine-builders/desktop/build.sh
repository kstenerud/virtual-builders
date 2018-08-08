#!/bin/bash

set -e
SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options]"
options_set_help_flag_and_description H "Create a Linux desktop container."
options_add_switch b bridge   "The bridge to connect to"             required br0
options_add_switch d desktop  "Desktop type to use"                  required mate
options_add_switch m path     "Path to mount as the user's home dir" required
options_add_switch n name     "Container name"                       required $(basename $(readlink -f "$SCRIPT_HOME"))
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

lxc_mount_host_owned_by home "$HOME_MOUNT" "/home/$USERNAME" w lxcfirstuser

lxc_run_installer_script $DESKTOP_TYPE $USERNAME $PASSWORD $IS_PRIVILEGED
