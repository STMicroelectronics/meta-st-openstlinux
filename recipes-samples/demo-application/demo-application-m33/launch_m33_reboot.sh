#!/bin/sh

ADDR="0x59"
ADDR_DEC=$((ADDR))

find_existing_rpmsg_dev() {
    for dir in /sys/class/rpmsg/rpmsg*; do
        if [ -d "$dir" ]; then
            src_file="$dir/src"
            if [ -f "$src_file" ]; then
                src_val=$(cat "$src_file")
                if [ "$src_val" -eq "$ADDR_DEC" ]; then
                    rpmsg_num=$(basename "$dir" | sed 's/rpmsg//')
                    echo "/dev/rpmsg${rpmsg_num}"
                    return 0
                fi
            fi
        fi
    done
    return 1
}

echo "Checking for existing rpmsg device with src=$ADDR_DEC..."
EXISTING_RPMSG_DEV=$(find_existing_rpmsg_dev)

if [ -n "$EXISTING_RPMSG_DEV" ]; then
	echo "echo START_REBOOT > $EXISTING_RPMSG_DEV"
	echo START_REBOOT > $EXISTING_RPMSG_DEV
fi
