#!/bin/bash
set +x

RPMSG_CREATE_EPT_BIN="rpmsg_create_ept"
RPMSG_CTRL_DEV="/dev/rpmsg_ctrl0"
ENDPOINT_NAME="shutdown"
ADDR="0x58"
TIMEOUT=10  # seconds to wait for /dev/rpmsg device

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
    echo "Found existing rpmsg device: $EXISTING_RPMSG_DEV"
    RPMSG_DEV="$EXISTING_RPMSG_DEV"
else
    echo "No existing rpmsg device found, creating new endpoint..."

    echo "Creating rpmsg endpoint..."
    $RPMSG_CREATE_EPT_BIN "$RPMSG_CTRL_DEV" "$ENDPOINT_NAME" "$ADDR"
    if [ $? -ne 0 ]; then
        echo "Failed to create rpmsg endpoint"
        exit 1
    fi

    echo "Waiting for rpmsg device to be created..."
    for ((i=0; i<TIMEOUT; i++)); do
        RPMSG_DEV=$(find_existing_rpmsg_dev)
        if [ -n "$RPMSG_DEV" ]; then
            echo "$RPMSG_DEV found."
            break
        fi
        sleep 1
    done

    if [ -z "$RPMSG_DEV" ]; then
        echo "Timeout waiting for rpmsg device"
        exit 1
    fi
fi

echo "Starting to read from $RPMSG_DEV and wait for 'shutdown' command..."

while true; do
    # Read up to 100 bytes (adjust size as needed) from the device
    line=$(sudo dd if=$RPMSG_DEV bs=128 count=1 2>/dev/null | strings)
    line=$(echo -n "$line" | tr -d '\r\n')

    case "$line" in
    shutdown)
        echo "Received shutdown command. Shutting down system..."
        # Perform system shutdown (requires appropriate permissions)
        systemctl poweroff
        exit 0
        ;;
    reboot)
        echo "Received reboot command. Shutting down system..."
        # Perform system reboot (requires appropriate permissions)
        echo warm > /sys/kernel/reboot/mode
        systemctl reboot
        exit 0
        ;;
    *)
        echo "Received unexpected message: '$line'"
        ;;
    esac
done
