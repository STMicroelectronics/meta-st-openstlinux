#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin

ln -s /proc/mounts /etc/mtab

if [ -n "$ROOTFS_DIR" ]; then
USERFS=
ROOTFS=
VENDORFS=
BOOTFS=

    if [ ! -e $ROOTFS_DIR/etc/.resized ]
    then
        for j in 0 1;
        do
            for i in 4 5 6 7 8 9 10;
            do
                DEVICE="/dev/mmcblk"$j"p"$i
                if [ -e $DEVICE ]; then
                    label=$(/sbin/e2label $DEVICE)
                    case $label in
                    user*)
                        USERFS=$DEVICE
                        ;;
                    root*)
                        ROOTFS=$DEVICE
                        ;;
                    vendor*)
                        VENDORFS=$DEVICE
                        ;;
                    boot*)
                        BOOTFS=$DEVICE
                        ;;
                     esac
                 fi
            done
        done

        # resize rootfs
        if [ -n "$ROOTFS" ]; then
            echo "RESIZE ROOTFS [$ROOTFS]"
            /sbin/resize2fs $ROOTFS
        fi
        # resize bootfs
        if [ -n "$BOOTFS" ]; then
            echo "RESIZE BOOTFS [$BOOTFS]"
            /sbin/e2fsck -f -y -c -C 0 $BOOTFS && /sbin/resize2fs $BOOTFS
        fi
        # resize vendorfs
        if [ -n "$VENDORFS" ]; then
            echo "RESIZE VENDORFS [$VENDORFS]"
            /sbin/e2fsck -f -y -c -C 0 $VENDORFS && /sbin/resize2fs $VENDORFS
        fi
        # resize userfs
        if [ -n "$USERFS" ]; then
            echo "RESIZE USERFS [$USERFS]"
            /sbin/e2fsck -f -y -c -C 0 $USERFS && /sbin/resize2fs $USERFS
        fi
        touch $ROOTFS_DIR/etc/.resized
    fi
fi
