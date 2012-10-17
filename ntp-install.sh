#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

run_command "Installing NTP server" apt-get install -y ntp
