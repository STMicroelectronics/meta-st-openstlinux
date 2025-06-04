#!/bin/sh -
# COPYRIGHT: Copyright (C) 2021, STMicroelectronics - All Rights Reserved

DEBUG=0
debug() {
    if [ $DEBUG -eq 1 ]; then
        echo $@ >> /tmp/stm32mp-net-alias-udev.log
        echo "NET ALIAS $@" > /dev/kmsg
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
alias)
    debug "--------ALIAS--------"
    debug "devpath=$devpath"
    debug "param1=$param1"
    if [ -n "$devpath" ]; then
        mkdir -p /tmp/net_alias/
        if [ -n "$param1" ]; then
                echo "$devpath" > /tmp/net_alias/$param1
        fi
    fi
    ;;
interface)
    if [ -n "$devpath" ]; then
        for talias in $(ls -1 /tmp/net_alias/*);
        do
            tmp_alias_path=$(cat $talias)
            if $(echo $devpath | grep -q $tmp_alias_path) ; then
                alias=$(basename $talias)
                interface=$(ls -1 /sys/$tmp_alias_path/net | head -n 1)
                soc_interface=$(basename $tmp_alias_path |  sed 's/\(.*\)\.\(.*\)/\2/' )
                debug "===> FOUND for $alias"
                debug "'    ' alias=$alias"
                debug "'    ' interface=$interface"
                debug "'    ' soc_interface=$soc_interface"
                debug "ip link property add dev $interface altname $alias"
                ip link property add dev $interface altname $alias
                debug "ip link property add dev $interface altname $alias.$soc_interface"
                ip link property add dev $interface altname $alias.$soc_interface
            fi

        done
    fi
    ;;
esac


