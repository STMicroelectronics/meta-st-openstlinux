#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin

resize_enabled() {
    return 0
}

resize_run() {
    ln -s /proc/mounts /etc/mtab

    if [ -n "$ROOTFS_DIR" ]; then
        if [ ! -e $ROOTFS_DIR/etc/.resized ]
        then
            # check command line to now storage device used
            if [ -n "$bootparam_root" ]; then
                debug "No e2fs compatible filesystem has been mounted, mounting $bootparam_root..."

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
                if [ -e "$bootparam_root" ]; then
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
