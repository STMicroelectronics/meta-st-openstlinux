#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin

rootfs_modules_enabled() {
    return 0
}

rootfs_modules_run() {
    if [ -n "$ROOTFS_DIR" ]; then
        # load kernel modules from rootfs
        udevadm control --stop-exec-queue
        rm -rf /etc/modprobe.d /lib/modules /lib/firmware
        ln -s $ROOTFS_DIR/etc/modprobe.d /etc/
        ln -s $ROOTFS_DIR/lib/modules /lib/
        ln -s $ROOTFS_DIR/lib/firmware /lib/
        echo '#' >>/etc/udev/rules.d/00-force-reload.rules
        udevadm control --reload
        udevadm control --start-exec-queue
        udevadm trigger --action=add
        udevadm settle
    fi
}
