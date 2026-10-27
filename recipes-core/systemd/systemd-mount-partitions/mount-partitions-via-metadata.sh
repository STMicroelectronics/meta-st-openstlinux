#!/bin/bash -
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

MOUNT_PARTITIONS_LIST=" "

declare -A METADATA_TYPE_IMAGE

# File systemd uuid by default and for A fw partitions
METADATA_TYPE_IMAGE[bootfs]="8da7c9d3-d368-487b-b28b-71e1b0c68cf0"
METADATA_TYPE_IMAGE[vendorfs]="3f427af9-e80f-4811-bd33-29aaf35a28f8"
METADATA_TYPE_IMAGE[rootfs]="b28961f8-c72c-4088-bbdb-c785861473fa"
METADATA_TYPE_IMAGE[userfs]="bf9b43d9-fcb3-4253-8297-afd9c68df1ef"

create_fwudata_config() {
    local _device=$1
    metadata1="/dev/disk/by-partlabel/metadata1"
    metadata2="/dev/disk/by-partlabel/metadata2"
    metadata1_erase=""
    metadata2_erase=""

    if [ "$_device" = "mmc0" ]; then
        block=mmcblk0
    else
        if [ "$_device" = "mmc0" ]; then
            block=mmcblk1
        else
            block=mmcblk2
        fi
    fi
    data=$(grep "PARTNAME=metadata1" /sys/class/block/$block*/uevent)
    if [ -n "$data" ]; then
        file=$(echo $data | cut -d':' -f 1)
        metadata1_sub=$(cat $file | grep DEVNAME | sed "s|DEVNAME=||")
        metadata1=$(echo /dev/$metadata1_sub)
    else
        # potentially we are on nor-sdcard or nor-emmc
        if [ -e /dev/mtd/by-name/metadata1 ]; then
            metadata1=/dev/mtd/by-name/metadata1
            metadata1_erase="0x1000"
        fi
    fi
    data=$(grep "PARTNAME=metadata2" /sys/class/block/mmcblk0*/uevent)
    if [ -n "$data" ]; then
        file=$(echo $data | cut -d':' -f 1)
        metadata2_sub=$(cat $file | grep DEVNAME | sed "s|DEVNAME=||")
        metadata2=$(echo /dev/$metadata2_sub)
    else
        if [ -e /dev/mtd/by-name/metadata2 ]; then
            metadata2=/dev/mtd/by-name/metadata2
            metadata2_erase="0x1000"
        fi
    fi
    echo "# create via boot from partitions mounted" > /etc/fwumdata_current.config
    echo "# device     offset   size erase" >> /etc/fwumdata_current.config
    echo "$metadata1 0x00000 0x118  $metadata1_erase"   >> /etc/fwumdata_current.config
    echo "$metadata2 0x00000 0x118  $metadata2_erase"   >> /etc/fwumdata_current.config
}

get_image_from_metadata() {
    local partname=$1
    local __result_uuid=$2
    local bank=0
    local image="unknown"
    [ -e /etc/fwumdata_current.config ] || eval $__result_uuid="unknown"
    # get active bank
    bank=$(/bin/fwumdata -c /etc/fwumdata_current.config | grep "Active Index" | sed "s|\s*Active Index:\s*\([01]\)|\1|")
    [ -n "$bank" ] || bank="0"
    # get image for this bank
    image=$(/bin/fwumdata -c /etc/fwumdata_current.config -l | grep -A9 ${METADATA_TYPE_IMAGE[${partname}]} |  grep -A2 "Bank ${bank}" | grep "Image GUID" | sed "s|\s*Image GUID:\s*\(.*\)$|\1|"
)
    [ -n "$image" ] || image="unknown"
    eval $__result_uuid="'$image'"
}
get_image_from_metadata_bank() {
    local __result_bank=$1
    local bank=0
    [ -e /etc/fwumdata_current.config ] || eval $__result_bank="0"
    # get active bank
    bank=$(/bin/fwumdata -c /etc/fwumdata_current.config | grep "Active Index" | sed "s|\s*Active Index:\s*\([01]\)|\1|")

    [ -n "$bank" ] || bank="0"
    eval $__result_bank="'$bank'"
}

get_type() {
    local  __resultvar=$1

    ROOT_TYPE="unknown"
    TYPE_AB="unknown"
    if [ -f /usr/bin/findmnt ];
    then
        ROOT_DEVICE=$(findmnt --noheadings --output=SOURCE / | cut -d'[' -f1)
        case $ROOT_DEVICE in
        ubi*)
            ROOT_TYPE="nand"
            ;;
        /dev/mmcblk0*)
            ROOT_TYPE="mmc0"
            ;;
        /dev/mmcblk1*)
            ROOT_TYPE="mmc1"
            ;;
        /dev/mmcblk2*)
            ROOT_TYPE="mmc2"
            ;;
        /dev/disk/by-*)
            LINK=$(/usr/bin/readlink $ROOT_DEVICE | tr '/' ' ' | tr '.' ' ' | sed "s/ //g")
            UUID=$(basename $ROOT_DEVICE)
            case $LINK in
            ubi*)
                ROOT_TYPE="nand"
                ;;
            mmcblk0*)
                ROOT_TYPE="mmc0"
                ;;
            mmcblk1*)
                ROOT_TYPE="mmc1"
                ;;
            mmcblk2*)
                ROOT_TYPE="mmc2"
                ;;
            esac
            ;;
        esac
    else
        if [ `cat /proc/cmdline | sed "s/.*mmcblk0.*/mmcblk0/" ` == "mmcblk0" ]; then
            ROOT_TYPE="mmc0"
        elif [ `cat /proc/cmdline | sed "s/.*mmcblk1.*/mmcblk1/" ` == "mmcblk1" ]; then
            ROOT_TYPE="mmc1"
        elif [ `cat /proc/cmdline | sed "s/.*mmcblk2.*/mmcblk2/" ` == "mmcblk2" ]; then
            ROOT_TYPE="mmc2"
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
    local _type_ab="A"
    local _option=" "
    case $_type in
        nand)
            # for the nand, fs can be not present in partition name
            _search="($_search|$(echo $_search | sed 's,fs$,,'))"
            local ubi_volumes=$(ls -1 -d /sys/class/ubi/ubi0_*)
            for f in $ubi_volumes;
            do
                if [ -r $f/name ];
                then
                    cat $f/name | grep -sq -E "^${_search}$"
                    if [ "$?" -eq 0 ];
                    then
                        _device="/dev/$(basename $f)"
                        _option="-t ubifs"
                        break;
                    fi
                fi
            done
            ;;
        mmc*)
            get_image_from_metadata_bank BANK
            echo "[DEBUG][medata] bank $BANK"
            [ "$BANK" = "0" ] || _type_ab="B"
            case ${_search} in
            rootfs*)
                get_image_from_metadata rootfs _device
                ;;
            bootfs*)
                get_image_from_metadata bootfs _device
                ;;
           vendorfs*)
                get_image_from_metadata vendorfs _device
                ;;
           userfs*)
                get_image_from_metadata userfs _device
                ;;
           esac
           [ -e ${_device} ] || _device="unknown"
           if [ "${_device}" = "unknown" ]; then
               # 'search' is not present on metadata, try to found it by partition name with suffix A or B
                mmc_id=$(echo $_type | sed "s/mmc//")
                local mmc_parts=$(ls -1 -d /sys/block/mmcblk${mmc_id}/mmcblk${mmc_id}p*)
                for f in $mmc_parts;
                do
                    if [ -r $f/uevent ];
                    then
                        if [ "${_type_ab}" = "A" ]; then
                            # search by partition name with B suffix
                            cat $f/uevent | grep PARTNAME | sed "s/PARTNAME=//" | grep -sq "^${_search}[-_]a"
                        elif [ "${_type_ab}" = "B" ]; then
                            # search by partition name with B suffix
                            cat $f/uevent | grep PARTNAME | sed "s/PARTNAME=//" | grep -sq "^${_search}[-_]b"
                        else
                            # search by partition name
                            cat $f/uevent | grep PARTNAME | sed "s/PARTNAME=//" | grep -sq "^${_search}"
                        fi
                        if [ "$?" -eq 0 ];
                        then
                            _device="/dev/$(basename $f)"
                            break;
                        fi
                    fi
                done
                [ -e ${_device} ] || _device="unknown"
                echo "[DEBUG] image found (${_search}A/B): $_device"
            fi
           if [ "${_device}" = "unknown" ]; then
                # 'search' is not present on metadata, and there is no partition name with suffix A or B
                # try to found by partition name without suffix
                mmc_id=$(echo $_type | sed "s/mmc//")
                local mmc_parts=$(ls -1 -d /sys/block/mmcblk${mmc_id}/mmcblk${mmc_id}p*)
                for f in $mmc_parts;
                do
                    if [ -r $f/uevent ];
                    then
                        # search by partition name
                        cat $f/uevent | grep PARTNAME | sed "s/PARTNAME=//" | grep -sq "^${_search}"
                        if [ "$?" -eq 0 ];
                        then
                            _device="/dev/$(basename $f)"
                            break;
                        fi
                    fi
                done
                [ -e ${_device} ] || _device="unknown"
                echo "[DEBUG] image found (${_search}): $_device"
           fi
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
        [ -e /etc/fwumdata.config ] && create_fwudata_config $TYPE
        for part in $MOUNT_PARTITIONS_LIST
        do
            part_label=$(echo $part | cut -d',' -f1)
            mountpoint=$(echo $part | cut -d',' -f2)
            found_devices DEVICE DEVICE_OPTION $TYPE $part_label
            echo "$part_label device: $DEVICE"
            [ -d $mountpoint ] || mkdir -p $mountpoint
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
