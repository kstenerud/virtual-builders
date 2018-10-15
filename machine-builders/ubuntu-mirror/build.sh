#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

lxc_preconfigure ubuntu 0 0 "Create an Ubuntu mirror container." L U
options_add_switch m path    "Path to mount as the mirror" required
options_add_switch r release "Release to mirror"           required bionic
lxc_run_standard_preinstall $@
lxc_apply_command_line_arguments

MOUNT="$(options_get_existing_directory m)"
RELEASE="$(options_get_value r)"

lxc_mount_host mirror "$MOUNT" "/var/spool/apt-mirror" w
lxc_run_installer_script "$RELEASE"
