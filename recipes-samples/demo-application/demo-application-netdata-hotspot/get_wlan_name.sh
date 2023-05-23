#!/bin/sh -
/sbin/ip link show wlan0 | head -n 1 | awk '{print $2}' |  tr '\n' ' ' | sed "s/: //"
