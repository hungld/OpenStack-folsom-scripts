#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_nova_volume ()
{
	pvcreate $LVM_BLOCK_DEVICE
	vgcreate $VOL_GROUP_NAME $LVM_BLOCK_DEVICE
	echo "# Nova volume" >> /etc/nova/nova.conf
	echo "iscsi_ip_address=$CC_NODE_DATA_IP" >> /etc/nova/nova.conf
	echo "volume_group=$VOL_GROUP_NAME" >> /etc/nova/nova.conf
}

run_command "Installing Nova Volume" apt-get install -y nova-volume
run_command "Configure Nova Volume" configure_nova_volume
run_command "Restart Nova Volume" service nova-volume restart
