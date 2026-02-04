#!/bin/sh -
action=$1
[ "$action" = "start" ] || /usr/sbin/stm32_usbotg_eth_config.sh stop
if [ -e /etc/default/usbotg ]; then
    source /etc/default/usbotg
    if [ -z ${DISABLE_USBOTG_GADGET+x} ]; then
        /usr/sbin/stm32_usbotg_eth_config.sh start
    else
        if [ ${DISABLE_USBOTG_GADGET} -eq  0 ]; then
            /usr/sbin/stm32_usbotg_eth_config.sh start
        fi
    fi
else
    /usr/sbin/stm32_usbotg_eth_config.sh start
fi
