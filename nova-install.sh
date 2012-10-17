#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_nova ()
{
	echo "sql_connection=mysql://nova:$NOVA_DB_PASSWORD@$MYSQL_HOST/nova" >> /etc/nova/nova.conf
	echo "rabbit_host=$RABBIT_HOST" >> /etc/nova/nova.conf
	echo "auth_strategy=keystone" >> /etc/nova/nova.conf
	echo "glance_api_servers=$GLANCE_HOST:9292" >> /etc/nova/nova.conf
	echo "glance_host=$GLANCE_HOST" >> /etc/nova/nova.conf
}

run_command "Installing Nova" apt-get install -y nova-common
run_command "Configure Nova" configure_nova
