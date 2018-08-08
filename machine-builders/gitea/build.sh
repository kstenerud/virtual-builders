#!/bin/bash

set -e
SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options]"
options_set_help_flag_and_description H "Create a Gitea container."
options_add_switch m path "Mount location for repostiroties" required
options_add_switch n name   "Container name"          required $(basename $(readlink -f "$SCRIPT_HOME"))
options_read_arguments $@

CONTAINER_DISTRO=edge
CONTAINER_NAME=$(options_get_value n)
HOME_DIRECTORY=$(options_get_value m)
MOUNT_PATHS=()
MOUNT_INDEX=1

lxc_build_standard_container $CONTAINER_DISTRO $CONTAINER_NAME

lxc_mount_host_owned_by home "$HOME_DIRECTORY" "/var/lib/gitea" w lxcfirstuser

lxc_run_installer_script
