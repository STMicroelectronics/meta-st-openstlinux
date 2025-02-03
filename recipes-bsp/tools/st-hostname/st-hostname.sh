#!/bin/sh -

# get mac-adress of end0
MAC=$(ip link show end0 | grep "link/ether"| awk '{print $2;}'| sed "s|00:80:e1||" | sed "s|10:e7:7a||" | tr ':' '-')
PREVIOUS_HOST=$(cat /etc/hostname)

if [ -z $MAC ]; then
    MAC=unknown
fi
if $(cat /etc/hostname | grep -qe "unknown"); then
    # reset hostname
    sed -i "s/unknown//" /etc/hostname
fi
if $(cat /etc/hostname | grep -qe "$MAC"); then
    #echo "[DEBUG] mac address already present"
    :
    # mac address already present on hostname
else
    #echo "[DEBUG] mac address NOT present"
    echo ${PREVIOUS_HOST}${MAC} > /etc/hostname
    hostnamectl hostname ${PREVIOUS_HOST}${MAC}
    hostnamectl --transient hostname ${PREVIOUS_HOST}${MAC}
    if $(grep -q SendHostname /usr/lib/systemd/network/80-wired.network) ; then
        sed -i "s|Hostname=.*$|Hostname=${PREVIOUS_HOST}${MAC}|" /usr/lib/systemd/network/80-wired.network
    else
        echo "SendHostname=true" >> /usr/lib/systemd/network/80-wired.network
        echo "Hostname=${PREVIOUS_HOST}${MAC}" >> /usr/lib/systemd/network/80-wired.network
    fi
fi

