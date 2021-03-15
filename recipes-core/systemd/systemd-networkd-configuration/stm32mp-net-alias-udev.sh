#!/bin/sh -
# COPYRIGHT: Copyright (C) 2021, STMicroelectronics - All Rights Reserved

DEBUG=0
debug() {
    if [ $DEBUG -eq 1 ]; then
        echo $@ >> /tmp/stm32mp-net-alias-udev.log
    fi
}

if [ $# -eq 2 ]; then
    action=$1
    devpath=$(echo $2 | sed "s/;//")
    param1=""
else
    action=$1
    param1=$2
    devpath=$(echo $3 | sed "s/;//")
fi
debug "Parameter: $1"
debug "Parameter: $2"
debug "Parameter: $3"

case $1 in
store)
    if [ -n "$devpath" ]; then
        interface_path=$(grep -l "$devpath" /tmp/net_interface/*)
        if [ $(echo $interface_path | wc -l) -eq 1 ]; then
            interface=$(basename $interface_path)
            debug "ip link property add dev $interface altname $param1"
            ip link property add dev $interface altname $param1
        fi
    fi
    ;;
interface)
   if [ -n "$devpath" ]; then
        # path have a format similar to /devices/platform/soc/5800a000.ethernet/net/eth0
        # need to remove the two last sub path
        interface_old=$(basename $devpath)
        tmp_path=$(dirname $devpath)
        net_name=$(basename $tmp_path)
        path=$(dirname $tmp_path)
        if [ "$net_name" == "net" ]; then
            mkdir -p /tmp/net_interface/
            if [ -n "$param1" ]; then
                echo "$path" > /tmp/net_interface/$param1
            else
                echo "$path" > /tmp/net_interface/$interface_old
            fi
        fi
    fi
    ;;
esac


