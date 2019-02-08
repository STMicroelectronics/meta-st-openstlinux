#!/bin/sh -
#===============================================================================
#
#          FILE: verify_eth0.sh
#
#         USAGE: ./verify_eth0.sh
#
#   DESCRIPTION: this script verify if the eth0 interface are already UP and 
#           have an ip address
#
#  ORGANIZATION: STMicroelectronics
#     COPYRIGHT: Copyright (C) 2017, STMicroelectronics - All Rights Reserved
#       CREATED: 11/04/17 11:21
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

INTERFACE=eth0

INTERFACE_UP=`ifconfig $INTERFACE | grep UP | wc -l`
INTERFACE_IP_ADDRESS=$(ifconfig $INTERFACE | awk '/inet addr/{print substr($2,6)}')

if [ $INTERFACE_UP -eq 1 ];
then
    if [ -n $INTERFACE_IP_ADDRESS ];
    then
        cp -f /lib/systemd/network/50-wired.network.nfs /lib/systemd/network/50-wired.network
    else
        cp -f /lib/systemd/network/50-wired.network.all /lib/systemd/network/50-wired.network
    fi
else
    cp -f /lib/systemd/network/50-wired.network.all /lib/systemd/network/50-wired.network
fi

systemctl restart systemd-networkd
