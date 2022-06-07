#!/bin/sh -
# Copyright (C) 2018, STMicroelectronics - All Rights Reserved

#
# For changing the password and SSID, please populate the file /etc/default/hostapd
# cat /etc/default/hostapd
# HOSTAPD_SSID=STExampleNetwork
# HOSTAPD_PASSWD=stm32mp1


if [ -f /etc/default/hostapd ];
then
    source /etc/default/hostapd
else
    HOSTAPD_SSID=STDemoNetwork
    HOSTAPD_PASSWD=stm32mp1
fi

WLAN_INTERFACE=wlan0

network_hotspot_install() {
# systemd netword hotsopt configuration
cat > /lib/systemd/network/hostapd.network << EOF
[Match]
Name=wlan0

[Network]
Address=192.168.72.1/24
DHCPServer=yes
IPForward=ipv4
IPMasquerade=yes

[DHCP]
CriticalConnection=true
UseTimezone=false

[DHCPServer]
EmitTimezone=no
EOF
# hotapd configuration
cat > /etc/hostapd.conf << EOF
interface=wlan0
driver=nl80211
# mode Wi-Fi (a = IEEE 802.11a, b = IEEE 802.11b, g = IEEE 802.11g)
hw_mode=g
ssid=$HOSTAPD_SSID
channel=7
wmm_enabled=0
macaddr_acl=0
# Wi-Fi closed, need an authentication
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$HOSTAPD_PASSWD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF
}
network_hotspot_erase() {
    rm -f /lib/systemd/network/hostapd.network
    rm -f /etc/hostapd.conf
}

# -------------------------------------------
# -------------------------------------------
if test `ifconfig $WLAN_INTERFACE > /dev/null 2>&1` ;
then
    echo "No WLAN0 interface available !!!!"
    exit 1
fi

case $1 in
start)
    #verify if file are present
    if test ! -f /lib/systemd/network/hostapd.network ;
    then
        network_hotspot_install
    fi
    # if not install file
    /sbin/ip link set wlan0 up
    # start service
    systemctl daemon-reload
    systemctl restart systemd-networkd.service
    systemctl restart hostapd
    ;;
stop)
    # stop service
    systemctl stop hostapd
    /sbin/ip link set wlan0 down
    # remove file
    network_hotspot_erase
    systemctl restart systemd-networkd.service
    systemctl daemon-reload
    ;;
*)
    echo "Help: $0 [start|stop]"
    ;;
esac
