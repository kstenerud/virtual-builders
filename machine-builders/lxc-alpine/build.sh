#!/bin/bash

set -e
SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/../../common/lxc-helpers.sh "$SCRIPT_HOME"
source $SCRIPT_HOME/../../common/options.sh
set -u

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options]"
options_set_help_flag_and_description H "Create an Alpine Linux playground."
options_add_switch n name "Container name"                required $(basename $(readlink -f "$SCRIPT_HOME"))
options_add_flag   P      "Create a privileged container" optional
options_read_arguments $@

CONTAINER_DISTRO=alpine
CONTAINER_NAME=$(options_get_value n)
IS_PRIVILEGED=$(options_get_value P)

lxc_build_standard_container $CONTAINER_DISTRO $CONTAINER_NAME
if [ $IS_PRIVILEGED == "true" ]; then
        lxc_mark_privileged
fi
