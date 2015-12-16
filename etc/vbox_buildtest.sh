#!/bin/bash
#####
# Test script which runs IncludeOS through
# virtualbox to see if each iteration is succesful

# Creates the IncludeOS image
source etc/install_from_bundle.sh

VB=VBoxManage
VMNAME="IncludeOS_VB_Test"
SERIAL_FILE="$(pwd)/testoutput.pipe"
DISK="etc/My_IncludeOS_Service.vdi"

$VB convertfromraw etc/My_IncludeOS_Service etc/My_IncludeOS_Service.vdi --format VDI

$VB createvm --name "$VMNAME" --ostype "Other" --register
$VB storagectl "$VMNAME" --name "IDE Controller" --add ide --bootable on
$VB storageattach "$VMNAME" --storagectl "IDE Controller" --port 0 --device 0 --type 'hdd' --medium "$DISK"

# Set the boot disk
$VB modifyvm "$VMNAME" --boot1 disk

# Serial port configuration to receive output
$VB modifyvm "$VMNAME" --uart1 0x3F8 4 --uartmode1 file $SERIAL_FILE

# NETWORK
$VB modifyvm "$VMNAME" --nic1 hostonly --nictype1 virtio --hostonlyadapter1 vboxnet0

# START VM
$VB startvm "$VMNAME" &

#
#
# TEST CODE HERE
# cat SOMEFILE
#

# Powers off and deletes the test VM
$VB controlvm "$VMNAME" --poweroff
$VB unregistervm "$VMNAME" --delete
rm testoutput.pipe
