#!/bin/bash

set -e
SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options]"
options_set_help_flag_and_description H "Create an Ubuntu mirror container."
options_add_switch b bridge   "The bridge to connect to"             required br0
options_add_switch m path     "Path to mount as the mirror"          required
options_add_switch n name     "Container name"                       required $(basename $(readlink -f "$SCRIPT_HOME"))
options_add_switch r release  "Release to mirror"                    required bionic
options_read_arguments $@

CONTAINER_DISTRO=ubuntu
CONTAINER_NAME=$(options_get_value n)
HOME_MOUNT=$(options_get_value m)
BRIDGE=$(options_get_value b)
DESKTOP_TYPE=$(options_get_value d)
RELEASE=$(options_get_value r)

lxc_build_standard_container $CONTAINER_DISTRO $CONTAINER_NAME

lxc_mount_host_owned_by mirror "$HOME_MOUNT" "/var/spool/apt-mirror" w lxcroot

lxc_run_installer_script $RELEASE
