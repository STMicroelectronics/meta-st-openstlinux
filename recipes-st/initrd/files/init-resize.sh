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
                        echo "RESIZE USERFS [$USERFS]"
                        /sbin/e2fsck -f -y -c -C 0 $USERFS && /sbin/resize2fs $USERFS
                        ;;
                    root*)
                        ROOTFS=$DEVICE
                        echo "RESIZE ROOTFS [$ROOTFS]"
                        /sbin/resize2fs $ROOTFS
                        ;;
                    vendor*)
                        VENDORFS=$DEVICE
                        echo "RESIZE VENDORFS [$VENDORFS]"
                        /sbin/e2fsck -f -y -c -C 0 $VENDORFS && /sbin/resize2fs $VENDORFS
                        ;;
                    boot*)
                        BOOTFS=$DEVICE
                        echo "RESIZE BOOTFS [$BOOTFS]"
                        /sbin/e2fsck -f -y -c -C 0 $BOOTFS && /sbin/resize2fs $BOOTFS
                        ;;
                     esac
                 fi
            done
        done

        touch $ROOTFS_DIR/etc/.resized
    fi
fi
