#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
echo "Sourcing helpers"
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

lxc_preconfigure alpine 0 0 "Create an Ubuntu Linux playground." P N K U L
lxc_run_standard_preinstall $@
lxc_apply_command_line_arguments
