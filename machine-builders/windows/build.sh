#!/bin/bash

set -e
SCRIPT_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source $SCRIPT_HOME/../../common/options.sh
source $SCRIPT_HOME/../../common/util.sh
set -u

options_set_usage "build.sh $(basename "$SCRIPT_HOME") [options]"
options_set_help_flag_and_description H "Create a Windows 10 VM."
options_add_switch n name      "Machine name"         required $(basename $(readlink -f "$SCRIPT_HOME"))
options_add_switch r gigabytes "RAM size"             required 16
options_add_switch p units     "Processor Units"      required 4
options_add_switch d gigabytes "Disk size"            required 128
options_add_switch v port      "VNC Port"             required 5910
options_add_switch b bridge    "Network Bridge"       required br0
options_add_switch I path      "Path to install disk" optional
options_add_switch D path      "Path to drivers disk" optional
options_add_switch M address   "Ethernet MAC Address" required random
options_add_switch m path      "Path to vm files"     required
options_read_arguments $@

MACHINE_NAME="$(options_get_value n)"
RAM_GB="$(options_get_value r)"
DISK_GB="$(options_get_value d)"
PROCESSORS="$(options_get_value p)"
VNC_PORT="$(options_get_value v)"
NETWORK_BRIDGE="$(options_get_value b)"
INSTALL_DISK="$(options_get_value I)"
DRIVERS_DISK="$(options_get_value D)"
MAC_ADDRESS="$(options_get_value M)"
VM_HOME="$(readlink -f "$(options_get_existing_directory m)")"
PRIMARY_HDD="$VM_HOME/primary.qcow2"


echo "Create Windows machine \"$MACHINE_NAME\" at $VM_HOME with ${RAM_GB}G RAM, $PROCESSORS processors, VNC $VNC_PORT"

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

# build_virt_command()
# {
#     ram_kb=$(($RAM_GB * 1024))

# 	echo -n "virt-install"
#     echo -n " --name=$MACHINE_NAME"
#     echo -n " --ram=$ram_kb"
#     echo -n " --cpu=host"
#     echo -n " --vcpus=$PROCESSORS"
#     echo -n " --os-type=windows"
#     echo -n " --os-variant=win10"
#     echo -n " --network bridge=$NETWORK_BRIDGE"
#     echo -n " --graphics vnc,listen=0.0.0.0,port=$VNC_PORT"
#     echo -n " --disk path=\"$PRIMARY_HDD\",format=qcow2,bus=virtio,cache=none"
#     if [ "X$INSTALL_DISK" != "X" ]; then
# 	    echo -n " --disk \"$INSTALL_DISK\",device=cdrom,bus=ide,perms=ro"
# 	fi
#     if [ "X$DRIVERS_DISK" != "X" ]; then
# 	    echo -n " --disk \"$DRIVERS_DISK\",device=cdrom,bus=ide,perms=ro"
# 	fi
#     # --cdrom "$INSTALL_DISK" \
# }
# eval "$(build_virt_command)"

generate_install_disk_xml()
{
    if [ "X$INSTALL_DISK" != "X" ]; then
        echo -n "<disk type='file' device='cdrom'>"
        echo -n "  <driver name='qemu' type='raw'/>"
        echo -n "  <source file='$INSTALL_DISK'/>"
        echo -n "  <backingStore/>"
        echo -n "  <target dev='hda' bus='ide'/>"
        echo -n "  <readonly/>"
        echo -n "  <alias name='ide0-0-0'/>"
        echo -n "  <address type='drive' controller='0' bus='0' target='0' unit='0'/>"
        echo -n "</disk>"
    fi
}

generate_drivers_disk_xml()
{
    if [ "X$DRIVERS_DISK" != "X" ]; then
        echo -n "<disk type='file' device='cdrom'>"
        echo -n "  <driver name='qemu' type='raw'/>"
        echo -n "  <source file='$DRIVERS_DISK'/>"
        echo -n "  <backingStore/>"
        echo -n "  <target dev='hdb' bus='ide'/>"
        echo -n "  <readonly/>"
        echo -n "  <alias name='ide0-0-1'/>"
        echo -n "  <address type='drive' controller='0' bus='0' target='0' unit='1'/>"
        echo -n "</disk>"
    fi
}

cat "$SCRIPT_HOME/windows-kvm-template.xml" | \
    fill_placeholder NAME $MACHINE_NAME | \
    fill_placeholder TITLE "Windows" | \
    fill_placeholder UUID $(uuidgen) | \
    fill_placeholder RAM_GB $RAM_GB | \
    fill_placeholder VCPUS $PROCESSORS | \
    fill_placeholder OVMF_CODE_IMAGE "$VM_HOME/OVMF_CODE.fd" | \
    fill_placeholder OVMF_VARS_IMAGE "$VM_HOME/OVMF_VARS.fd" | \
    fill_placeholder CLOVER_IMAGE "$VM_HOME/Clover.qcow2" | \
    fill_placeholder HDD_IMAGE "$PRIMARY_HDD" | \
    fill_placeholder NETWORK_BRIDGE "$NETWORK_BRIDGE" | \
    fill_placeholder MAC_ADDRESS "$MAC_ADDRESS" | \
    fill_placeholder INSTALL_DISK "$(generate_install_disk_xml)" | \
    fill_placeholder DRIVERS_DISK "$(generate_drivers_disk_xml)" | \
    fill_placeholder VNC_PORT $VNC_PORT > "$VM_HOME/${MACHINE_NAME}.xml"

virsh define "$VM_HOME/${MACHINE_NAME}.xml"
virsh start $MACHINE_NAME
