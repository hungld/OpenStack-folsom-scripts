#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_glance()
{
	echo "service_host = $KEYSTONE_HOST" >> /etc/glance/glance-api-paste.ini
	echo "service_port = 5000" >> /etc/glance/glance-api-paste.ini
	echo "auth_host = $KEYSTONE_HOST" >> /etc/glance/glance-api-paste.ini
	echo "auth_port = 35357" >> /etc/glance/glance-api-paste.ini
	echo "auth_protocol = http" >> /etc/glance/glance-api-paste.ini
	echo "auth_uri = http://$KEYSTONE_HOST:5000/" >> /etc/glance/glance-api-paste.ini
	echo "admin_tenant_name = $SERVICE_TENANT_NAME" >> /etc/glance/glance-api-paste.ini
	echo "admin_user = glance" >> /etc/glance/glance-api-paste.ini
	echo "admin_password = $GLANCE_USER_PASSWORD" >> /etc/glance/glance-api-paste.ini
	
	sed -i 's/#flavor=/flavor = keystone/g' /etc/glance/glance-api.conf
	
	echo "service_host = $KEYSTONE_HOST" >> /etc/glance/glance-registry-paste.ini
        echo "service_port = 5000" >> /etc/glance/glance-registry-paste.ini
        echo "auth_host = $KEYSTONE_HOST" >> /etc/glance/glance-registry-paste.ini
        echo "auth_port = 35357" >> /etc/glance/glance-registry-paste.ini
        echo "auth_protocol = http" >> /etc/glance/glance-registry-paste.ini
        echo "auth_uri = http://$KEYSTONE_HOST:5000/" >> /etc/glance/glance-registry-paste.ini
        echo "admin_tenant_name = $SERVICE_TENANT_NAME" >> /etc/glance/glance-registry-paste.ini
        echo "admin_user = glance" >> /etc/glance/glance-registry-paste.ini
        echo "admin_password = $GLANCE_USER_PASSWORD" >> /etc/glance/glance-registry-paste.ini
	
	sed -i "s%sql_connection = sqlite:////var/lib/glance/glance.sqlite%sql_connection = mysql://glance:$GLANCE_DB_PASSWORD@$MYSQL_HOST/glance%g" /etc/glance/glance-registry.conf
	sed -i 's/#flavor=/flavor = keystone/g' /etc/glance/glance-registry.conf
	
	echo "create database glance;" > /tmp/glance.sql
	echo "grant all privileges on glance.* to glance@'%' identified by '$GLANCE_DB_PASSWORD';" >> /tmp/glance.sql
	mysql -u root -p$MYSQL_PASSWORD < /tmp/glance.sql
	glance-manage db_sync
}

run_command "Installing Glance" apt-get install -y glance glance-api glance-client glance-common glance-registry python-glance
run_command "Configure Glance" configure_glance
run_command "Restarting Glance API" service glance-api restart
run_command "Restarting Glance Registry" service glance-registry restart
