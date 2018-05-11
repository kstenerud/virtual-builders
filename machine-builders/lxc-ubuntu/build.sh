#!/bin/bash

set -e
SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options]"
options_set_help_flag_and_description H "Create an Ubuntu Linux playground."
options_add_switch n name "Container name" required $(basename $(readlink -f "$SCRIPT_HOME"))
options_read_arguments $@

CONTAINER_NAME=$(options_get_value n)
CONTAINER_DISTRO=ubuntu

lxc_build_standard_container $CONTAINER_DISTRO $CONTAINER_NAME
