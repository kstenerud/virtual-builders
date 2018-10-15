#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

lxc_preconfigure bionic 1000 1000 "Create a photo gallery container." L R
options_add_switch m path "Mount point for gallery files" required
lxc_run_standard_preinstall $@
lxc_apply_command_line_arguments

MOUNT="$(options_get_existing_directory m)"

lxc_mount_host home "$MOUNT" "/var/photos" r
lxc_run_installer_script
