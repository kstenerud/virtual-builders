#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

lxc_preconfigure bionic 0 0 "Create a PI-Hole container." L R U
options_add_switch m path  "Mount point for config"  required
lxc_run_standard_preinstall $@
lxc_apply_command_line_arguments

MOUNT="$(options_get_value m)"

lxc_mount_host config "$MOUNT" "/etc/pihole" w
lxc_run_installer_script
