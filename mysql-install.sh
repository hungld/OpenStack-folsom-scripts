#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

export DEBIAN_FRONTEND=noninteractive

function configure_mysql()
{
	sed -i "s/127.0.0.1/$MYSQL_HOST/g" /etc/mysql/my.cnf
	mysqladmin -u root password $MYSQL_PASSWORD
}

run_command "Installing MySQL server" apt-get install -y mysql-server python-mysqldb
run_command "Configure MySQL server" configure_mysql
run_command "Restarting MySQL server" service mysql restart
