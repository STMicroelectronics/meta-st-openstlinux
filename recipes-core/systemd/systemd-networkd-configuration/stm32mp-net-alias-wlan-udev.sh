#!/bin/sh -
# COPYRIGHT: Copyright (C) 2022, STMicroelectronics - All Rights Reserved

TYPE=$1
INTERFACE=$2
if [ "$TYPE" = "wlan" ]; then
    ip links show wlan0 > /dev/null 2> /dev/null
    if [ $? -eq 1 ]; then
        ip link property add dev $INTERFACE altname wlan0
    fi
fi
