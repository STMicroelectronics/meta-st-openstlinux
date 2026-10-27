#!/bin/sh
function pty_exec() {
    cmd=$1
    #pty=$(tty > /dev/null 2>&1; echo $?)
    # no need to associate a new pty
    pty=0
    if [ $pty -eq 0 ]; then
        cmd=$(echo $cmd | sed "s#\"#'#g")
        event_cmd=$(echo /usr/local/demo/bin/touch-event-gtk-player -w $SCREEN_WIDTH -h $SCREEN_HEIGHT --graph \"$cmd\")
        eval $event_cmd > /dev/null 2>&1
    else
        # no pty
        echo "NO PTY"
        event_cmd=$(echo /usr/local/demo/bin/touch-event-gtk-player -w $SCREEN_WIDTH -h $SCREEN_HEIGHT --graph \"$cmd\")
        script -qc "$event_cmd" > /dev/null 2>&1
    fi
}

# Detect if GPU are present or not
gpu_presence=0
if [ -f /etc/default/weston ] && $(grep "^OPTARGS" /etc/default/weston | grep -q "pixman" ) ;
then
        echo "Without GPU"
        ADDONS="videoconvert ! video/x-raw,format=BGRx ! queue !"
elif [ $(cat /proc/modules | grep etnaviv | wc -l) -gt 1 ]; then
        echo "With Etnaviv GPU"
        ADDONS="videoconvert ! video/x-raw,format=BGRx ! queue !"
else
        echo "With GPU"
        gpu_presence=1
        ADDONS=""
fi

# Detect size of screen
SCREEN_WIDTH=$(wayland-info -i zxdg_output_manager_v1 | grep -A2 "name" | tr '\n' ' ' | sed "s|--|#|g" |tr '#' '\n' | grep -v pipewire | tr '\t' '\n' | grep logical_width | sed -r "s/logical_width: ([0-9]+),.*/\1/")
SCREEN_HEIGHT=$(wayland-info -i zxdg_output_manager_v1 | grep -A2 "name" | tr '\n' ' ' | sed "s|--|#|g" |tr '#' '\n' | grep -v pipewire | tr '\t' '\n' | grep logical_width | sed -r "s/.*logical_height: ([0-9]+).*/\1/")

if [ $gpu_presence -eq 0 ] || [ $SCREEN_HEIGHT -lt 480 ];
then
        VIDEO_FILE=/usr/local/demo/media/ST19619_ST_Company_Video_16_9_EN_272p.webm
else
        VIDEO_FILE=/usr/local/demo/media/ST2297_visionv3.webm
fi

# Audio
AUDIOSINK=""
COMPATIBLE_BOARD=$(tr -d '\0' < /proc/device-tree/compatible | sed "s|st,|,|g" | cut -d ',' -f2)
case $COMPATIBLE_BOARD in
stm32mp257f-dk*|stm32mp257f-ev1*)
        hdmi_status=$(cat /sys/class/drm/card0/*HDMI*/status)
        if [ "$hdmi_status" = "disconnected" ]; then
		if ! $(wpctl status -n 2>/dev/null| grep -q "bluez"); then
	                AUDIOSINK="audio-sink='fakesink '"
		fi
        fi
        ;;
        *)
        ;;
esac

echo "Gstreamer graph:"
# WARNING: need to add a space before last ' to avoid that ' are taken by name and not by video-sink
GRAPH="playbin3 uri=file://$VIDEO_FILE video-sink='$ADDONS gtkwaylandsink name=gtkwsink ' $AUDIOSINK "
echo "   $GRAPH"

pty_exec "$GRAPH"
