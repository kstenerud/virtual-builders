#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

lxc_preconfigure edge 1000 1000 "Create a Tumblr backup container." L U
options_add_switch m path "Mount location for blogs" required
lxc_run_standard_preinstall $@
lxc_apply_command_line_arguments

MOUNT="$(options_get_value m)"

lxc_mount_host blogs "$MOUNT" "/home/tumblr/blogs" w
lxc_run_installer_script
