#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function add_repository() {
	echo deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/folsom main >> /etc/apt/sources.list.d/folsom.list &&	apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 5EDB1B62EC4926EA
}

run_command "Adding the official folsom repositories" add_repository
run_command "Update Ubuntu" apt-get update
run_command "Upgrade Ubuntu" apt-get upgrade -y
