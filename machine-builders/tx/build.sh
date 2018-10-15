#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

lxc_preconfigure ubuntu 1000 1000 "Create a transfer desktop container." L p P R u U
options_add_switch m path "Path to mount as the user's home dir" required
lxc_run_standard_preinstall $@
lxc_apply_command_line_arguments

USERNAME="$(options_get_value u)"
PASSWORD="$(options_get_value p)"
MOUNT="$(options_get_existing_directory m)"

lxc_mount_host home "$MOUNT" "/home/$USERNAME" w
lxc_run_installer_script "$USERNAME" "$PASSWORD"
