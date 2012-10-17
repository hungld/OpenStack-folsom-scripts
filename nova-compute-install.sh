#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_nova_compute ()
{
	echo "# nova-compute configuration" >> /etc/nova/nova.conf
	echo "vnc_enabled=True" >> /etc/nova/nova.conf
	echo "novncproxy_base_url=http://$VNC_PUB_HOST:6080/vnc_auto.html" >> /etc/nova/nova.conf
	echo "vpvncproxy_base_url=http://$VNC_PUB_HOST:6081/console" >> /etc/nova/nova.conf
	echo "vncserver_listen=$CC_NODE_CTRL_IP" >> /etc/nova/nova.conf
	echo "vncserver_proxyclient_address=$CC_NODE_CTRL_IP" >> /etc/nova/nova.conf
	echo "# nova-network configuration" >> /etc/nova/nova.conf
	echo "public_interface=$PUB_IFACE_NAME" >> /etc/nova/nova.conf
	echo "network_manager=nova.network.manager.VlanManager" >> /etc/nova/nova.conf
	echo "vlan_interface=$DATA_IFACE_NAME" >> /etc/nova/nova.conf
	echo "vlan_start=$FIRST_VLAN_ID" >> /etc/nova/nova.conf
	echo "fixed_range=$FIXED_IP_RANGE" >> /etc/nova/nova.conf
	echo "network_size=$NETWORK_SIZE" >> /etc/nova/nova.conf
	echo "routing_source_ip=$CC_NODE_PUB_IP" >> /etc/nova/nova.conf
	echo "my_ip=$CC_NODE_CTRL_IP" >> /etc/nova/nova.conf
}

run_command "Installing Nova" apt-get install -y nova-compute nova-network
run_command "Configure Nova Compute and Network" configure_nova_compute
