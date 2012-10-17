#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

function update_config()
{
	echo -e "restrict $CTRL_RANGE mask $CTRL_MASK\nbroadcast $CTRL_BROADCAST\ndisable auth\nbroadcastclient" >> /etc/ntp.conf
}

run_command "Update config" update_config
run_command "Restart NTP server" service ntp restart
