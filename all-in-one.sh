#!/bin/bash

./adding_folsom_repository.sh
./ntp-install.sh
./ntp-init.sh
./mysql-install.sh
./rabbit-install.sh
./keystone-install.sh
./keystone-init.sh
./glance-install.sh
./glance-init.sh
./nova-install.sh
./nova-api-install.sh
./nova-compute-install.sh
./nova-vnc-install.sh
./cinder-volume-install.sh
./horizon-install.sh
