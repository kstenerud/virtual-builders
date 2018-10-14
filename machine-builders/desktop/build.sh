#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

lxc_preconfigure ubuntu 1000 1000 "Create a Linux desktop container." L p P R u U
options_add_switch d desktop  "Desktop type to use"                  required mate
options_add_switch m path     "Path to mount as the user's home dir" required
lxc_run_standard_preinstall $@
lxc_apply_command_line_arguments

USERNAME="$(options_get_value u)"
PASSWORD="$(options_get_value p)"
MOUNT="$(options_get_value m)"
DESKTOP_TYPE="$(options_get_value d)"
IS_PRIVILEGED="$(options_get_value P)"

if [ -z "$IS_PRIVILEGED" ]; then lxc_fix_unprivileged_dbus; fi
lxc_mount_host home "$MOUNT" "/home/$USERNAME" w
lxc_run_installer_script "$DESKTOP_TYPE" "$USERNAME" "$PASSWORD" "$IS_PRIVILEGED"
