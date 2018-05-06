#!/bin/bash

set -eu

SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
source $SCRIPT_HOME/../common/options.sh
source $SCRIPT_HOME/../common/util.sh

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options] <vm-home>"
options_set_help_flag_and_description H "Create a MacOS VM."
options_add_switch n name      "Machine name"         required macos
options_add_switch r gigabytes "RAM size"             required 16
options_add_switch p units     "Processor Units"      required 4
options_add_switch d gigabytes "Disk size"            required 128
options_add_switch e path      "Path to emulator"     required /usr/bin/qemu-system-x86_64
options_add_switch v port      "VNC Port"             required 5920
options_add_switch b bridge    "Network Bridge"       required br0
options_add_switch M address   "Ethernet MAC Address" required random
options_add_switch I path      "Path to install disk" optional
options_read_arguments $@

if [ $(options_count_free_arguments) -lt 1 ]; then
    options_print_help
    exit 1
fi

MACHINE_NAME=$(options_get_value n)
RAM_GB=$(options_get_value r)
DISK_GB=$(options_get_value d)
PROCESSORS=$(options_get_value p)
EMULATOR_PATH="$(options_get_value e)"
VNC_PORT="$(options_get_value v)"
NETWORK_BRIDGE="$(options_get_value b)"
INSTALL_DISK="$(options_get_value I)"
VM_HOME="$(readlink -f "$(options_get_free_argument 0)")"
PRIMARY_HDD="$VM_HOME/primary.qcow2"
MAC_ADDRESS="$(options_get_value M)"


echo "Create MacOS machine \"$MACHINE_NAME\" at $VM_HOME with ${RAM_GB}G RAM, $PROCESSORS processors, VNC $VNC_PORT"

if [ ! -d "$VM_HOME" ]; then
    echo "Creating VM directory at $VM_HOME"
    mkdir -p "$VM_HOME"
fi

if [ ! -f "$PRIMARY_HDD" ]; then
    echo "Creating new ${DISK_GB}G hdd image at $PRIMARY_HDD"
    qemu-img create -f qcow2 "$PRIMARY_HDD" ${DISK_GB}G
fi

if [ "$MAC_ADDRESS" == "random" ]; then
    MAC_ADDRESS=$(generate_mac_address)
fi

try_copy "$SCRIPT_HOME/Clover.qcow2" "$VM_HOME/Clover.qcow2"
try_copy "$SCRIPT_HOME/OVMF_CODE.fd" "$VM_HOME/OVMF_CODE.fd"
try_copy "$SCRIPT_HOME/OVMF_VARS.fd" "$VM_HOME/OVMF_VARS.fd"

generate_install_disk_xml()
{
    if [ "X$INSTALL_DISK" != "X" ]; then
        echo -n "<disk type='file' device='cdrom'>"
        echo -n "  <driver name='qemu' type='raw' cache='none'/>"
        echo -n "  <source file='$INSTALL_DISK'/>"
        echo -n "  <readonly/>"
        echo -n "  <target dev='sdc' bus='sata'/>"
        echo -n "  <boot order='3'/>"
        echo -n "  <address type='drive' controller='0' bus='0' target='0' unit='2'/>"
        echo -n "</disk>"
    fi
}

cat "$SCRIPT_HOME/mac-hs-kvm-template.xml" | \
    fill_placeholder NAME $MACHINE_NAME | \
    fill_placeholder TITLE "MacOS High Sierra" | \
    fill_placeholder UUID $(uuidgen) | \
    fill_placeholder RAM_GB $RAM_GB | \
    fill_placeholder VCPUS $PROCESSORS | \
    fill_placeholder OVMF_CODE_IMAGE "$VM_HOME/OVMF_CODE.fd" | \
    fill_placeholder OVMF_VARS_IMAGE "$VM_HOME/OVMF_VARS.fd" | \
    fill_placeholder CLOVER_IMAGE "$VM_HOME/Clover.qcow2" | \
    fill_placeholder HDD_IMAGE "$PRIMARY_HDD" | \
    fill_placeholder MAC_ADDRESS "$MAC_ADDRESS" | \
    fill_placeholder EMULATOR_PATH "$EMULATOR_PATH" | \
    fill_placeholder NETWORK_BRIDGE "$NETWORK_BRIDGE" | \
    fill_placeholder INSTALL_DISK "$(generate_install_disk_xml)" | \
    fill_placeholder VNC_PORT $VNC_PORT > "$VM_HOME/${MACHINE_NAME}.xml"

# Qemu won't start otherwise
export QEMU_AUDIO_DRV=alsa

virsh define "$VM_HOME/${MACHINE_NAME}.xml"
virsh start $MACHINE_NAME
