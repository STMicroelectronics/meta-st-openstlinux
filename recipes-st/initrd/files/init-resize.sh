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
            for j in 0 1;
            do
                for i in 3 4 5 6 7 8 9 10;
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
            done

            touch $ROOTFS_DIR/etc/.resized
        fi
    fi
}
