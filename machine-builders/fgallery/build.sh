#!/bin/bash

set -e
SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options]"
options_set_help_flag_and_description H "Create an nginx container."
options_add_switch m path "Mount location for photo files" required
options_add_switch n name   "Container name"          required $(basename $(readlink -f "$SCRIPT_HOME"))
options_read_arguments $@

CONTAINER_DISTRO=bionic
CONTAINER_NAME=$(options_get_value n)
HOME_DIRECTORY=$(options_get_value m)

lxc_build_standard_container $CONTAINER_DISTRO $CONTAINER_NAME

lxc_mount_host photos "$HOME_DIRECTORY" "/var/photos" r

lxc_run_installer_script
