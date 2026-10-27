#!/bin/sh

get_webcam_device() {
    V4L_DEVICE=""
    PIPEWIRE_SRC=""
    for video in $(find /sys/class/video4linux -name "video*" -type l | sort);
    do
        if ! $(cat $video/name | grep -q "dcmi") ; then
            V4L_DEVICE="device=/dev/$(basename $video)"
            PIPEWIRE_SRC=$(gst-device-monitor-1.0 Video/Source:image/jpeg 2>/dev/null | grep gst-launch | tail -n 1 | sed "s|\s*gst-launch-1.0 \(.*\) !.*|\1|" )
            break;
        fi
    done
}

# ------------------------------
#         main
# ------------------------------

# graphic backend detection
if [ -f /etc/default/weston ] && $(grep "^OPTARGS" /etc/default/weston | grep -q "pixman" ) ;
then
	echo "Without GPU"
	ADDONS="videoconvert ! queue !"
else
	echo "With GPU"
	ADDONS=""
fi

GST_SOURCE=""

echo "search webcam"
get_webcam_device
echo ">>>>$V4L_DEVICE<<"

if [ -n "$V4L_DEVICE" ]; then
    # suppose we have a webcam
    WIDTH=640
    HEIGHT=480

    GST_CAPS="video/x-raw, width=$WIDTH, height=$HEIGHT"
    V4L_OPT="io-mode=4"
    v4l2-ctl --set-parm=20
#     if [ -n "$PIPEWIRE_SRC" ]; then
#         GST_SOURCE="$PIPEWIRE_SRC"
#     else
        GST_SOURCE="v4l2src $V4L_DEVICE $V4L_OPT"
     ADDONS="videoconvert ! video/x-raw,format=RGB16 ! queue !"
#    fi
fi

# Detect size of screen
SCREEN_WIDTH=$(wayland-info -i zxdg_output_manager_v1 | grep -A2 "name" | tr '\n' ' ' | sed "s|--|#|g" |tr '#' '\n' | grep -v pipewire | tr '\t' '\n' | grep logical_width | sed -r "s/logical_width: ([0-9]+),.*/\1/")
SCREEN_HEIGHT=$(wayland-info -i zxdg_output_manager_v1 | grep -A2 "name" | tr '\n' ' ' | sed "s|--|#|g" |tr '#' '\n' | grep -v pipewire | tr '\t' '\n' | grep logical_width | sed -r "s/.*logical_height: ([0-9]+).*/\1/")
echo "SCREEN_WIDTH=$SCREEN_WIDTH"
echo "SCREEN_HEIGHT=$SCREEN_HEIGHT"
