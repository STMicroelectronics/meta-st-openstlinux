#!/bin/sh -
WLAN_INTERFACE=$(/usr/local/demo/application/netdata/bin/get_wlan_name.sh 2> /dev/null)

if [ -n "$WLAN_INTERFACE" ]; then
    LIST_ETH=$(/sbin/ip link | grep ^[1-9] | grep -v lo | grep -v "$WLAN_INTERFACE" | awk '{print $2;}' | sed "s/://")
else
    LIST_ETH=$(/sbin/ip link | grep ^[1-9] | grep -v lo | awk '{print $2;}' | sed "s/://")
fi

IP_ADDRESS=""
for i in $LIST_ETH;
do
    IP=$(/sbin/ip addr show $i  | grep "inet " | awk '{print $2;}' | sed "s/\([0-9]*.[0-9]*.[0-9]*.[0-9]*\).*/\1/")
    if [ -n "$IP" ]; then
        IP_ADDRESS="$IP_ADDRESS http://$IP:19999"
    fi
done
echo $IP_ADDRESS
