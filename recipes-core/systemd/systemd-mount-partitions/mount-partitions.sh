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

MOUNT_PARTITIONS_LIST=""

declare -A MOUNT_DISK_UUID_ROOTFS MOUNT_DISK_UUID_B_ROOTFS
declare -A MOUNT_DISK_UUID_BOOTFS MOUNT_DISK_UUID_B_BOOTFS
declare -A MOUNT_DISK_UUID_VENDORFS MOUNT_DISK_UUID_B_VENDORFS
declare -A MOUNT_DISK_UUID_USERFS MOUNT_DISK_UUID_B_USERFS

# File systemd uuid by default and for A fw partitions
MOUNT_DISK_UUID_ROOTFS[mmc0]="e91c4e10-16e6-4c0e-bd0e-77becf4a3582"
MOUNT_DISK_UUID_BOOTFS[mmc0]="c9b01b31-b604-4c2a-95b4-e23ab45fd0c5"
MOUNT_DISK_UUID_VENDORFS[mmc0]="8abdaae5-d940-463a-8326-a2c6af788fe6"
MOUNT_DISK_UUID_USERFS[mmc0]="2d750516-056c-4fae-9d73-f3141f1cffb4"

MOUNT_DISK_UUID_ROOTFS[mmc1]="491f6117-415d-4f53-88c9-6e0de54deac6"
MOUNT_DISK_UUID_BOOTFS[mmc1]="0ef36fac-9ba4-4e39-823a-bbb2336c32be"
MOUNT_DISK_UUID_VENDORFS[mmc1]="9fdbbc13-65d3-4419-9395-88c694a4ea79"
MOUNT_DISK_UUID_USERFS[mmc1]="e873e5be-10d5-4670-b8f1-2905b5e7d992"

# File systemd uuid for B fw partitions
MOUNT_DISK_UUID_B_ROOTFS[mmc0]="360db83f-c038-4e10-ae79-1dce8846d2f0"
MOUNT_DISK_UUID_B_BOOTFS[mmc0]="67a73cea-322c-42c0-b477-6ef0039fefed"
MOUNT_DISK_UUID_B_VENDORFS[mmc0]="d168dbce-65f3-423c-86af-a11528890b30"
MOUNT_DISK_UUID_B_USERFS[mmc0]="7e036063-979d-4000-949d-33ab3e987de0"

MOUNT_DISK_UUID_B_ROOTFS[mmc1]="6e01295a-8f81-47d5-945c-cb144ae7500c"
MOUNT_DISK_UUID_B_BOOTFS[mmc1]="f2c429f5-9000-4201-aa0f-96a95ea8d9f9"
MOUNT_DISK_UUID_B_VENDORFS[mmc1]="4752ba24-2e0d-45b9-9c42-0028ece6e74b"
MOUNT_DISK_UUID_B_USERFS[mmc1]="445a0e58-aa95-4e75-8c4f-ff603dddb60f"

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

get_type() {
    local  __resultvar=$1
    local  __resultab=$2

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
            TYPE_AB="A"
            [ "$UUID" = "${MOUNT_DISK_UUID_B_ROOTFS[mmc0]}" -o "$UUID" = "${MOUNT_DISK_UUID_B_ROOTFS[mmc1]}" ] && TYPE_AB="B";
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
    eval $__resultab="'$TYPE_AB'"

}

found_devices() {
    local __resultvar=$1
    local __resultopt=$2
    local _type=$3
    local _search=$4
    local _type_ab=$5
    local _device="unknown"
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
            if [ ! "${_type_ab}" = "unknown" ]; then
                case ${_search} in
                rootfs*)
                    if [ "${_type_ab}" = "B" ]; then
                         _device="/dev/disk/by-partuuid/${MOUNT_DISK_UUID_B_ROOTFS[${_type}]}"
                    else
                         _device="/dev/disk/by-partuuid/${MOUNT_DISK_UUID_ROOTFS[${_type}]}"
                    fi
                    ;;
                bootfs*)
                    if [ "${_type_ab}" = "B" ]; then
                         _device="/dev/disk/by-partuuid/${MOUNT_DISK_UUID_B_BOOTFS[${_type}]}"
                    else
                         _device="/dev/disk/by-partuuid/${MOUNT_DISK_UUID_BOOTFS[${_type}]}"
                    fi
                    ;;
                vendorfs*)
                    if [ "${_type_ab}" = "B" ]; then
                         _device="/dev/disk/by-partuuid/${MOUNT_DISK_UUID_B_VENDORFS[${_type}]}"
                    else
                         _device="/dev/disk/by-partuuid/${MOUNT_DISK_UUID_VENDORFS[${_type}]}"
                    fi
                    ;;
                userfs*)
                    if [ "${_type_ab}" = "B" ]; then
                         _device="/dev/disk/by-partuuid/${MOUNT_DISK_UUID_B_USERFS[${_type}]}"
                    else
                         _device="/dev/disk/by-partuuid/${MOUNT_DISK_UUID_USERFS[${_type}]}"
                    fi
                    ;;
                esac
                [ -f ${_device} ] || _device="unknown"
            fi
            echo "[DEBUG] image found by uuid (${_search}) : $_device"
            if [ "${_device}" = "unknown" ]; then
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
                echo "[DEBUG] image found (${_search} A/B): $_device"
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
        get_type TYPE TYPEAB
        echo "TYPE of support detected: $TYPE"
        for part in $MOUNT_PARTITIONS_LIST
        do
            part_label=$(echo $part | cut -d',' -f1)
            mountpoint=$(echo $part | cut -d',' -f2)
            found_devices DEVICE DEVICE_OPTION $TYPE $part_label $TYPEAB
            echo "$part_label device: $DEVICE"
            [ -d $mountpoint ] || mkdir -p $mountpoint
            [ -e $DEVICE ] && mount $DEVICE_OPTION $DEVICE $mountpoint
        done
        [ -e /etc/fwumdata.config ] && create_fwudata_config $TYPE
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
