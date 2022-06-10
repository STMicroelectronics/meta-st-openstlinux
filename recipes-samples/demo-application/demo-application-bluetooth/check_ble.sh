#!/bin/sh
script -qc "su -c 'hciconfig hci0 up || echo ko > /tmp/ble'"

if [ -e /tmp/ble ]; then
    rm /tmp/ble
    exit 1;
else
    exit 0;
fi
