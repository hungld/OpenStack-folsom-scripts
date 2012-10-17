#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function init_glance ()
{
	mkdir /tmp/image
	PWD=$(pwd)
	cd /tmp/image
	wget -c http://uec-images.ubuntu.com/releases/precise/release/ubuntu-12.04-server-cloudimg-amd64.tar.gz
	tar xzvf ubuntu-12.04-server-cloudimg-amd64.tar.gz
	export OS_TENANT_NAME=admin
	export OS_USERNAME=admin
	export OS_PASSWORD=$ADMIN_PASSWORD
	export OS_AUTH_URL="http://$KEYSTONE_HOST:5000/v2.0/"
	glance add name="Ubuntu" is_public=true container_format=ovf disk_format=qcow2 < precise-server-cloudimg-amd64.img
	cd $PWD
}

run_command "Init Glance" init_glance
