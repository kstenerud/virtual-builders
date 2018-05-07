#!/bin/bash

set -eu

SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
LXC_SOURCE_HOME="$SCRIPT_HOME"
source $SCRIPT_HOME/../common/lxc-helpers.sh
source $SCRIPT_HOME/../common/options.sh

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options]"
options_set_help_flag_and_description H "Create a key management services container."
options_add_switch n name "Container name" required kmsserver
options_read_arguments $@

CONTAINER_NAME=$(options_get_value n)
CONTAINER_DISTRO=alpine

lxc_build_standard_container $CONTAINER_DISTRO $CONTAINER_NAME
lxc_run_installer_script
