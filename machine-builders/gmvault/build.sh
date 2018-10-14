#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

lxc_preconfigure edge 1000 1000 "Create a GMail backup container." L R U
options_add_switch e email "Email address to backup" required
options_add_switch m path  "Mount point for backup"  required
lxc_run_standard_preinstall $@
lxc_apply_command_line_arguments

EMAIL_ADDRESS="$(options_get_value e)"
MOUNT="$(options_get_value m)"

lxc_mount_host backup "$MOUNT" "/home/gmail" w
lxc_run_installer_script "$EMAIL_ADDRESS"
