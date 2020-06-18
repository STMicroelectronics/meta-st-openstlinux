#!/bin/sh -
#echo "Parameter number $#" >> /tmp/toto.log
action=$1
devpath=$2
#echo "Parameter: $1" >> /tmp/toto.log
#echo "Parameter: $2" >> /tmp/toto.log

case $1 in
unload)
    modprobe -r usbip-core
    modprobe -r usbip-host
    kill -9 `pgrep usbipd`
    exit 0
    ;;
esac

subpath=$(echo $2 | sed "s|.*/\([^/]*\)|\1|")
#echo "subpath  >$subpath<" >> /tmp/toto.log
if $(echo $subpath | grep -q ":");
then
    #echo "No valid path" >> /tmp/toto.log
    exit 0
fi

# if usbip-core are not loaded, do nothing
if [ -z "$(cat /proc/modules | grep usbip-core)"  ]; then
   exit 0
fi

case $1 in
add)
    usbip bind -b $subpath
    ;;
remove)
    usbip bind -b $subpath
    ;;
esac

