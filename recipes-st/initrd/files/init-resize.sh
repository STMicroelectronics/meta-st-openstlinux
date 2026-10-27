#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin

resize_enabled() {
    return 0
}

SDCARD_A_UUID="e91c4e10-16e6-4c0e-bd0e-77becf4a3582"
# bootfs vendorfs rootfs userfs
SDCARD_A_PARTITION="c9b01b31-b604-4c2a-95b4-e23ab45fd0c5 8abdaae5-d940-463a-8326-a2c6af788fe6 e91c4e10-16e6-4c0e-bd0e-77becf4a3582 2d750516-056c-4fae-9d73-f3141f1cffb4"

SDCARD_B_UUID="360db83f-c038-4e10-ae79-1dce8846d2f0"
SDCARD_B_PARTITION="67a73cea-322c-42c0-b477-6ef0039fefed d168dbce-65f3-423c-86af-a11528890b30 360db83f-c038-4e10-ae79-1dce8846d2f0 7e036063-979d-4000-949d-33ab3e987de0"

EMMC_A_UUID="491f6117-415d-4f53-88c9-6e0de54deac6"
EMMC_A_PARTITION="0ef36fac-9ba4-4e39-823a-bbb2336c32be 9fdbbc13-65d3-4419-9395-88c694a4ea79 491f6117-415d-4f53-88c9-6e0de54deac6 e873e5be-10d5-4670-b8f1-2905b5e7d992"

EMMC_B_UUID="6e01295a-8f81-47d5-945c-cb144ae7500c"
EMMC_B_PARTITION="f2c429f5-9000-4201-aa0f-96a95ea8d9f9 4752ba24-2e0d-45b9-9c42-0028ece6e74b 6e01295a-8f81-47d5-945c-cb144ae7500c 445a0e58-aa95-4e75-8c4f-ff603dddb60f"


resize_run() {
    ln -s /proc/mounts /etc/mtab

    if [ -n "$ROOTFS_DIR" ]; then
        if [ ! -e $ROOTFS_DIR/etc/.resized ]
        then
            # check command line to now storage device used
            if [ -n "$bootparam_root" ]; then
                debug "No e2fs compatible filesystem has been mounted, mounting $bootparam_root..."
                root_partuuid=""
                not_fully_resized=1
                if [ "`echo ${bootparam_root} | cut -c1-5`" = "UUID=" ]; then
                    root_uuid=`echo $bootparam_root | cut -c6-`
                    bootparam_root="/dev/disk/by-uuid/$root_uuid"
                elif [ "`echo ${bootparam_root} | cut -c1-9`" = "PARTUUID=" ]; then
                    root_partuuid=`echo $bootparam_root | cut -c10-`
                    bootparam_root="/dev/disk/by-partuuid/$root_partuuid"
                elif [ "`echo ${bootparam_root} | cut -c1-10`" = "PARTLABEL=" ]; then
                    root_partlabel=`echo $bootparam_root | cut -c11-`
                    bootparam_root="/dev/disk/by-partlabel/$root_partlabel"
                elif [ "`echo ${bootparam_root} | cut -c1-6`" = "LABEL=" ]; then
                    root_label=`echo $bootparam_root | cut -c7-`
                    bootparam_root="/dev/disk/by-label/$root_label"
                fi
                if [ ! "X$root_partuuid" = "X" ]; then
                    if [ "$root_partuuid" = "$SDCARD_A_UUID" ]; then
                        LIST_PARTITION_UUID=$SDCARD_A_PARTITION
                    fi
                    if [ "$root_partuuid" = "$SDCARD_B_UUID" ]; then
                        LIST_PARTITION_UUID=$SDCARD_B_PARTITION
                    fi
                    if [ "$root_partuuid" = "$EMMC_A_UUID" ]; then
                        LIST_PARTITION_UUID=$EMMC_A_PARTITION
                    fi
                    if [ "$root_partuuid" = "$EMMC_B_UUID" ]; then
                        LIST_PARTITION_UUID=$EMMC_B_PARTITION
                    fi
                    not_fully_resized=0
                    for uuid in $LIST_PARTITION_UUID;
                    do
                        DEVICE="/dev/disk/by-partuuid/$uuid"
                        echo "DEVICE $DEVICE"
                        [ ! -e $DEVICE ] && { not_fully_resized=1 ; echo "DEVICE $DEVICE doesn't exist"; continue; }
                        if [ "$uuid" = "$root_partuuid" ]; then
                            echo "RESIZE [$uuid]"
                            /sbin/resize2fs $DEVICE
                        else
                            echo "FSCK/RESIZE [$uuid]"
                            /sbin/e2fsck -f -y -c -C 0 $DEVICE && /sbin/resize2fs $DEVICE
                        fi
                    done
                fi
                if [ $not_fully_resized -eq 1 -a -e "$bootparam_root" ]; then
                    bootparam_root_device=$(busybox readlink $bootparam_root -f)
                    j=$(echo $bootparam_root_device | sed "s|/dev/mmcblk\([0-2]\)p.*|\1|")
                    for i in 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20;
                    do
                        DEVICE="/dev/mmcblk"$j"p"$i
                        if [ -e $DEVICE ]; then
                            label=$(/sbin/e2label $DEVICE 2> /dev/null)
                            if [ $? -eq 0 ]; then
                                case $label in
                                user*)
                                    echo "RESIZE USERFS [$DEVICE]"
                                    /sbin/e2fsck -f -y -c -C 0 $DEVICE && /sbin/resize2fs $DEVICE
                                    ;;
                                root*)
                                    echo "RESIZE ROOTFS [$DEVICE]"
                                    /sbin/resize2fs $DEVICE
                                    ;;
                                vendor*)
                                    echo "RESIZE VENDORFS [$DEVICE]"
                                    /sbin/e2fsck -f -y -c -C 0 $DEVICE && /sbin/resize2fs $DEVICE
                                    ;;
                                boot*)
                                    echo "RESIZE BOOTFS [$DEVICE]"
                                    /sbin/e2fsck -f -y -c -C 0 $DEVICE && /sbin/resize2fs $DEVICE
                                    ;;
                                *)
                                    ;;
                                esac
                            fi
                        fi
                    done
                    touch $ROOTFS_DIR/etc/.resized
                fi
            fi
        fi
    fi
}
