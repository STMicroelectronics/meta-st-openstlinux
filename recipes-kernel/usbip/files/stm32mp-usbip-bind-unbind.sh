#!/bin/sh -
#echo "Parameter number $#" >> /tmp/usbip.log
action=$1
devpath=$2
#echo "Parameter: $1" >> /tmp/usbip.log
#echo "Parameter: $2" >> /tmp/usbip.log

case $1 in
unload)
    modprobe -r usbip-core
    modprobe -r usbip-host
    kill -9 `pgrep usbipd`
    exit 0
    ;;
esac

subpath=$(echo $2 | sed "s|.*/\([^/]*\)|\1|")
#echo "subpath  >$subpath<" >> /tmp/usbip.log
if $(echo $subpath | grep -q ":");
then
    #echo "No valid path" >> /tmp/usbip.log
    exit 0
fi

# if usbip-core are not loaded, do nothing
if [ -z "$(cat /proc/modules | grep usbip_core)"  ]; then
   #echo "no module usbip_core loaded" >> /tmp/usbip.log
   exit 0
fi

case $1 in
add)
    #echo ">>> bind $subpath" >> /tmp/usbip.log
    usbip bind -b $subpath
    ;;
remove)
    #echo "<<< unbind $subpath" >> /tmp/usbip.log
    usbip unbind -b $subpath
    ;;
esac

