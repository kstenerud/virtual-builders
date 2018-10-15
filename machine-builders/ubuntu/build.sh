#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/options.sh
source $SCRIPT_HOME/../../common/util.sh
set -u

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options] <vm-home>"
options_set_help_flag_and_description H "Create a Windows 10 VM."
options_add_switch n name      "Machine name"         required $(basename $(readlink -f "$SCRIPT_HOME"))
options_add_switch r gigabytes "RAM size"             required 16
options_add_switch p units     "Processor Units"      required 4
options_add_switch d gigabytes "Disk size"            required 128
options_add_switch v port      "VNC Port"             required 5910
options_add_switch b bridge    "Network Bridge"       required br0
options_add_switch I path      "Path to install disk" optional
options_add_switch M address   "Ethernet MAC Address" required random
options_add_switch m path      "Path to vm files"     required
options_read_arguments $@

if [ $(options_count_free_arguments) -lt 1 ]; then
    options_print_help_and_exit 1
fi

MACHINE_NAME="$(options_get_value n)"
RAM_GB="$(options_get_value r)"
DISK_GB="$(options_get_value d)"
PROCESSORS="$(options_get_value p)"
VNC_PORT="$(options_get_value v)"
NETWORK_BRIDGE="$(options_get_value b)"
INSTALL_DISK="$(options_get_value I)"
MAC_ADDRESS="$(options_get_value M)"
VM_HOME="$(readlink -f "$(options_get_existing_directory m)")"
PRIMARY_HDD="$VM_HOME/primary.qcow2"


echo "Create Ubuntu machine \"$MACHINE_NAME\" at $VM_HOME with ${RAM_GB}G RAM, $PROCESSORS processors, VNC $VNC_PORT"

if [ ! -d "$VM_HOME" ]; then
    echo "Creating VM directory at $VM_HOME"
    mkdir -p "$VM_HOME"
fi

if [ ! -f "$PRIMARY_HDD" ]; then
    echo "Creating new ${DISK_GB}G hdd image at $PRIMARY_HDD"
    qemu-img create -f qcow2 "$PRIMARY_HDD" ${DISK_GB}G
fi

if [ "$MAC_ADDRESS" == "random" ]; then
    MAC_ADDRESS="$(generate_mac_address)"
fi

build_virt_command()
{
    ram_mb="$(($RAM_GB * 1024))"

	echo -n "virt-install"
    echo -n " --name=$MACHINE_NAME"
    echo -n " --ram=$ram_mb"
    echo -n " --cpu=host"
    echo -n " --vcpus=$PROCESSORS"
    echo -n " --os-type=linux"
    echo -n " --os-variant=ubuntu17.04"
    echo -n " --network bridge=$NETWORK_BRIDGE"
    echo -n " --graphics vnc,listen=0.0.0.0,port=$VNC_PORT"
    echo -n " --disk path=\"$PRIMARY_HDD\",format=qcow2,bus=virtio,cache=none"
    if [ ! -z "$INSTALL_DISK" ]; then
        echo -n " --cdrom \"$INSTALL_DISK\""
    fi
}
eval "$(build_virt_command)"
