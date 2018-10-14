#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

lxc_preconfigure alpine 0 0 "Create a key management services container." L U
lxc_run_standard_preinstall $@
lxc_apply_command_line_arguments

lxc_run_installer_script
