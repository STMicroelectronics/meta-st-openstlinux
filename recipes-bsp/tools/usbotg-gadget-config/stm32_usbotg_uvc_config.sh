#!/bin/sh
#
# Copyright (c) 2024 STMicroelectronics.
# All rights reserved.
#
# This software is licensed under MIT License terms that can be found here:
#
# https://opensource.org/license/mit

# This script configures USB Gadget configfs to use USB OTG as a USB serial
# and USB UVC gadgets

configfs="/sys/kernel/config/usb_gadget"
g=g1
c=c.1
d="${configfs}/${g}"
func_uvc=uvc.0

VENDOR_ID="0x483"
PRODUCT_ID="0x5740"

create_frame() {
	# Example usage:
	# create_frame <function name> <width> <height> <format> <name>

	FUNCTION=$1
	WIDTH=$2
	HEIGHT=$3
	FORMAT=$4
	NAME=$5

	wdir=${d}/functions/$FUNCTION/streaming/$FORMAT/$NAME/${HEIGHT}p

	mkdir -p $wdir
	echo $WIDTH > $wdir/wWidth
	echo $HEIGHT > $wdir/wHeight
    # YUV422 format
    echo $(( $WIDTH * $HEIGHT * 2 )) > $wdir/dwMaxVideoFrameBufferSize
    # MJPEG format
    #echo $(( $WIDTH * $HEIGHT )) > $wdir/dwMaxVideoFrameBufferSize
    # dwFrameInterfal is in 100-ns units (fps = 1/(dwFrameInterval * 10000000))
    # The targetted FPS is a parameter. default is 30fps -> 333333
    echo $((10000000 / $FPS)) > $wdir/dwFrameInterval
}

do_start() {
    if [ ! -d ${configfs} ]; then
        modprobe libcomposite
        if [ ! -d ${configfs} ]; then
        exit 1
        fi
    fi

    if [ -d ${d} ]; then
        exit 0
    fi

    udc=$(ls -1 /sys/class/udc/)
    if [ -z $udc ]; then
        echo "No UDC driver registered"
        exit 1
    fi

    mkdir ${d}
    echo ${VENDOR_ID} > ${d}/idVendor
    echo ${PRODUCT_ID} > ${d}/idProduct

    # Both interface may not operate independently
    echo 0xEF > ${d}/bDeviceClass
    echo 0x02 > ${d}/bDeviceSubClass
    echo 0x01 > ${d}/bDeviceProtocol

    mkdir -p ${d}/strings/0x409
    tr -d '\0' < /proc/device-tree/serial-number > ${d}/strings/0x409/serialnumber
    echo "STMicroelectronics" > ${d}/strings/0x409/manufacturer
    echo "STM32MP" > ${d}/strings/0x409/product

    # Config
    mkdir -p ${d}/configs/${c}
    mkdir -p ${d}/configs/${c}/strings/0x409
    echo "CDC UVC" > ${d}/configs/${c}/strings/0x409/configuration

    # Create UVC function
    mkdir -p ${d}/functions/${func_uvc}
    # mjpeg 480p config (not working with gstreamer uvcsink => need to debug it)
    # The width and height are parameters of this script. Default is 640x480
    create_frame ${func_uvc} $FRAME_WIDTH $FRAME_HEIGHT mjpeg m
    # yuv420 480p config
    # The width and height are parameters of this script. Default is 640x480
    create_frame ${func_uvc} $FRAME_WIDTH $FRAME_HEIGHT uncompressed u
    mkdir -p ${d}/functions/${func_uvc}/streaming/header/h

    cd ${d}/functions/${func_uvc}/streaming/header/h
	ln -s ../../uncompressed/u
	ln -s ../../mjpeg/m
	cd ../../class/fs
	ln -s ../../header/h
	cd ../../class/hs
	ln -s ../../header/h
	cd ../../class/ss
	ln -s ../../header/h
	cd ../../../control
	mkdir header/h
	ln -s header/h class/fs
	ln -s header/h class/ss
	cd ../../../
    # Set the packet size: uvc gadget max size is 3k...
	echo 3072 > functions/${func_uvc}/streaming_maxpacket
	echo 2048 > functions/${func_uvc}/streaming_maxpacket
	echo 1024 > functions/${func_uvc}/streaming_maxpacket
    echo 1 > functions/${func_uvc}/streaming_interval
    ln -s ${d}/functions/${func_uvc} ${d}/configs/${c}

    # Bind USB Device Controller
    echo ${udc} > ${d}/UDC

	# user information
	echo "#########################################################"
	echo "# for sending data with this uvc gadget, use the tools"
	echo "# uvc-gadget"
	echo "#"
	echo "# send a mir via uvc gadget"
	echo "# $> uvc-gadget uvc.0"
	echo "# send the camera content (libcamera)"
	echo "# $> uvc-gadget -c 0 uvc.0"
	

}

do_stop() {
    streaming_dir=${d}/functions/${func_uvc}/streaming
    if [ ! -d "${streaming_dir}" ];
    then
        echo "Nothing to do"
        return
    fi

    echo "" > ${d}/UDC

    # Delete UVC gadget
    [ -L ${d}/configs/${c}/${func_uvc} ] && rm ${d}/configs/${c}/${func_uvc}
	[ -L ${d}/functions/${func_uvc}/control/class/fs/h ] && rm ${d}/functions/${func_uvc}/control/class/fs/h
	[ -L ${d}/functions/${func_uvc}/control/class/ss/h ] && rm ${d}/functions/${func_uvc}/control/class/ss/h
	[ -L ${d}/functions/${func_uvc}/streaming/class/fs/h ] && rm ${d}/functions/${func_uvc}/streaming/class/fs/h
	[ -L ${d}/functions/${func_uvc}/streaming/class/hs/h ] && rm  ${d}/functions/${func_uvc}/streaming/class/hs/h
	[ -L ${d}/functions/${func_uvc}/streaming/class/ss/h ] && rm  ${d}/functions/${func_uvc}/streaming/class/ss/h
	[ -L ${d}/functions/${func_uvc}/streaming/header/h/m ] && rm  ${d}/functions/${func_uvc}/streaming/header/h/m
	[ -d ${d}/functions/${func_uvc}/streaming/mjpeg/m ] && rmdir ${d}/functions/${func_uvc}/streaming/mjpeg/m/*/
	[ -d ${d}/functions/${func_uvc}/streaming/mjpeg/m ] && rmdir ${d}/functions/${func_uvc}/streaming/mjpeg/m
	[ -L ${d}/functions/${func_uvc}/streaming/header/h/u ] && rm  ${d}/functions/${func_uvc}/streaming/header/h/u
	[ -d ${d}/functions/${func_uvc}/streaming/uncompressed/u ] && rmdir ${d}/functions/${func_uvc}/streaming/uncompressed/u/*/
	[ -d ${d}/functions/${func_uvc}/streaming/uncompressed/u ] && rmdir ${d}/functions/${func_uvc}/streaming/uncompressed/u
	[ -d ${d}/functions/${func_uvc}/streaming/header/h ] && rmdir ${d}/functions/${func_uvc}/streaming/header/h
	[ -d ${d}/functions/${func_uvc}/control/header/h ] && rmdir ${d}/functions/${func_uvc}/control/header/h
    [ -d ${d}/functions/${func_uvc} ] && rmdir ${d}/functions/${func_uvc}

    [ -d ${d}/configs/${c}/strings/0x409 ] && rmdir ${d}/configs/${c}/strings/0x409
    [ -d ${d}/configs/${c} ] && rmdir ${d}/configs/${c}
    [ -d ${d}/strings/0x409/ ] && rmdir ${d}/strings/0x409/
    [ -d ${d} ] && rmdir ${d}
}

FRAME_WIDTH=${2:-320}  # Default width to 320 if not provided
FRAME_HEIGHT=${3:-240} # Default height to 240 if not provided
FPS=${4:-30}          # Default to 30 FPS if not provided

case $1 in
    start)
        echo "Start UVC gadget with $FRAME_WIDTH x $FRAME_HEIGHT resolution @$FPS fps"
        do_start
        ;;
    stop)
        echo "Stop UVC gadget"
        do_stop
        ;;
    restart)
        echo "Stop UVC gadget"
        do_stop
        sleep 1
        echo "Start UVC gadget with $FRAME_WIDTH x $FRAME_HEIGHT resolution @$FPS fps"
        do_start
        ;;
    *)
        echo "Usage: $0 <stop | start | restart> [fps]"
        ;;
esac
