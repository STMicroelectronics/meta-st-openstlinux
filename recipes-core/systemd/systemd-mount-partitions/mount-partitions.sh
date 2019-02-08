#!/bin/sh -
#===============================================================================
#
#          FILE: mount-partitions.sh
#
#         USAGE: ./mount-partitions.sh [start|stop]
#
#   DESCRIPTION: mount partitions

#  ORGANIZATION: STMicroelectronics
#     COPYRIGHT: Copyright (C) 2018, STMicroelectronics - All Rights Reserved
#       CREATED: 01/09/2018 13:36
#      REVISION:  ---
#===============================================================================

MOUNT_PARTITIONS_LIST=""

get_type() {
    local  __resultvar=$1
    ROOT_TYPE="unknown"
    if [ -f /usr/bin/findmnt ];
    then
        ROOT_DEVICE=$(findmnt --noheadings --output=SOURCE / | cut -d'[' -f1)
        case $ROOT_DEVICE in
        ubi*)
            ROOT_TYPE="nand"
            ;;
        /dev/mmcblk0*)
            ROOT_TYPE="sdmmc"
            ;;
        /dev/mmcblk1*)
            ROOT_TYPE="mmc"
            ;;
        esac
    else
        if [ `cat /proc/cmdline | sed "s/.*mmcblk0.*/mmcblk0/" ` == "mmcblk0" ]; then
            ROOT_TYPE="sdmmc"
        elif [ `cat /proc/cmdline | sed "s/.*mmcblk1.*/mmcblk1/" ` == "mmcblk1" ]; then
            ROOT_TYPE="mmc"
        elif [ `cat /proc/cmdline | sed "s/.*ubi0.*/ubi0/" ` == "ubi0" ]; then
            ROOT_TYPE="nand"
        fi
    fi
    eval $__resultvar="'$ROOT_TYPE'"
}

found_devices() {
    local __resultvar=$1
    local __resultopt=$2
    local _type=$3
    local _search=$4
    local _device="unknown"
    local _option=" "
    case $_type in
    nand)
        for f in ubi0_0 ubi0_1 ubi0_2 ubi0_3;
        do
            if [ -r /sys/class/ubi/$f ];
            then
                cat /sys/class/ubi/$f/name | grep -sq $_search
                if [ $? -eq 0 ];
                then
                    _device="/dev/$f"
                    _option="-t ubifs"
                    break;
                fi
            fi
        done
        ;;
    sdmmc)
        for f in 1 2 3 4 5 6 7 8 9 10;
        do
            if [ -r /sys/block/mmcblk0/mmcblk0p$f/uevent ];
            then
                cat /sys/block/mmcblk0/mmcblk0p$f/uevent | grep PARTNAME | sed "s/PARTNAME=//" | grep -sq $_search
                if [ $? -eq 0 ];
                then
                    _device="/dev/mmcblk0p$f"
                    break;
                fi
            fi
        done
        ;;
    mmc)
        for f in 1 2 3 4 5 6 7 8 9 10;
        do
            if [ -r /sys/block/mmcblk1/mmcblk1p$f/uevent ];
            then
                cat /sys/block/mmcblk1/mmcblk1p$f/uevent | grep PARTNAME | sed "s/PARTNAME=//" | grep -sq $_search
                if [ $? -eq 0 ];
                then
                    _device="/dev/mmcblk1p$f"
                    break;
                fi
            fi
        done
        ;;
    esac
    eval $__resultvar="'$_device'"
    eval $__resultopt="'$_option'"
}

case "$1" in
    start)
        # mount partitions
        get_type TYPE
        echo "TYPE of support detected: $TYPE"
        for part in $MOUNT_PARTITIONS_LIST
        do
            part_label=$(echo $part | cut -d',' -f1)
            mountpoint=$(echo $part | cut -d',' -f2)
            found_devices DEVICE DEVICE_OPTION $TYPE $part_label
            echo "$part_label device: $DEVICE"
            [ -e $DEVICE ] && mount $DEVICE_OPTION $DEVICE $mountpoint
        done
        ;;
    stop)
        # umount partitions
        for part in $MOUNT_PARTITIONS_LIST
        do
            mountpoint=$(echo $part | cut -d',' -f2)
            umount $mountpoint
        done
        ;;
    *)
        echo "Usage: $0 [start|stop]"
        ;;
esac
