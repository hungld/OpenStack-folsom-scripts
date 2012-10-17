#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function configure_keystone()
{
	TMP_KEYSTONE_SQL_FILE=/tmp/keystone.db.sql
	KEYSTONE_CONFIG=/etc/keystone/keystone.conf
	sed -i "s/# admin_token = ADMIN/admin_token = $ADMIN_TOKEN/g" $KEYSTONE_CONFIG
	sed -i "s%connection = sqlite:////var/lib/keystone/keystone.db%connection = mysql://keystone:$KEYSTONE_DB_PASSWORD@$MYSQL_HOST/keystone%g" $KEYSTONE_CONFIG
	echo "create database keystone;" > $TMP_KEYSTONE_SQL_FILE
	echo "grant all privileges on keystone.* to keystone@'%' identified by '$KEYSTONE_DB_PASSWORD';" >> $TMP_KEYSTONE_SQL_FILE
	mysql -uroot -p$MYSQL_PASSWORD < $TMP_KEYSTONE_SQL_FILE

}

run_command "Installing Keystone" apt-get install -y keystone python-keystone python-keystoneclient
run_command "Configure Keystone" configure_keystone
run_command "Restart Keystone" service keystone restart
run_command "Sync db Keystone" keystone-manage db_sync

