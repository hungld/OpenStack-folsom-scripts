#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_nova_api ()
{
	echo "public_interface=$PUB_IFACE_NAME" >> /etc/nova/nova.conf
	echo "multi_host=True" >> /etc/nova/nova.conf
	
	echo "service_host = $KEYSTONE_HOST" >> /etc/nova/api-paste.ini
	echo "service_port = 5000" >> /etc/nova/api-paste.ini
	sed -i "s/auth_host = 127.0.0.1/auth_host = $KEYSTONE_HOST/g" /etc/nova/api-paste.ini
	echo "auth_uri = http://$KEYSTONE_HOST:5000/" >> /etc/nova/api-paste.ini
	sed -i "s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT_NAME/g" /etc/nova/api-paste.ini
	sed -i "s/%SERVICE_USER%/nova/g" /etc/nova/api-paste.ini
	sed -i "s/%SERVICE_PASSWORD%/$NOVA_USER_PASSWORD/g" /etc/nova/api-paste.ini
}

function create_database ()
{
	echo "create database nova;" > /tmp/nova.sql
	echo "grant all privileges on nova.* to nova@'%' identified by '$NOVA_DB_PASSWORD';" >> /tmp/nova.sql
	mysql -u root -p$MYSQL_PASSWORD < /tmp/nova.sql
}

function restart_nova ()
{
	for svc in nova-api nova-cert nova-consoleauth nova-scheduler; do service $svc restart; done
}

run_command "Installing Nova API" apt-get install -y nova-api nova-cert nova-consoleauth nova-scheduler nova-network
#run_command "Stop network service" service nova-network stop
service nova-network stop > /dev/null
run_command "Create Database" create_database
run_command "Database Sync" nova-manage db sync
run_command "Initial network data" nova-manage network create private --fixed_range_v4=$FIXED_IP_RANGE --num_networks=1 --bridge_interface=$DATA_IFACE_NAME --vlan=$FIRST_VLAN_ID --network_size=$NETWORK_SIZE
run_command "Initial network data" nova-manage floating create --ip_range=$FLOATING_IP_RANGE --interface=$PUB_IFACE_NAME
run_command "Configure Nova API" configure_nova_api
run_command "Restart Nova API, Cert, Consoleauth, Scheduler" restart_nova
