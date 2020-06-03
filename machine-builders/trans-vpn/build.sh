#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

lxc_preconfigure ubuntu 112 119 "Transmission + PureVPN." L U
options_add_switch m path    "Path to mount for downloads" required
lxc_run_standard_preinstall $@
lxc_apply_command_line_arguments

MOUNT="$(options_get_existing_directory m)"

lxc_mount_host mirror "$MOUNT" "/var/lib/transmission-daemon/downloads" w
lxc_run_installer_script
