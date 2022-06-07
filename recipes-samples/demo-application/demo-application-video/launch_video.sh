#!/bin/sh
function pty_exec() {
    cmd=$1
    pty=$(tty > /dev/null 2>&1; echo $?)
    if [ $pty -eq 0 ]; then
        cmd=$(echo $cmd | sed "s#\"#'#g")
        event_cmd=$(echo /usr/local/demo/bin/touch-event-gtk-player -w $SCREEN_WIDTH -h $SCREEN_HEIGHT --graph \"$cmd\")
        eval $event_cmd > /dev/null 2>&1
    else
        # no pty
        echo "NO PTY"
        event_cmd=$(echo /usr/local/demo/bin/touch-event-gtk-player -w $SCREEN_WIDTH -h $SCREEN_HEIGHT --graph \'$cmd\')
        script -qc "$event_cmd" > /dev/null 2>&1
    fi
}

# Detect if GPU are present or not
gpu_presence=0
if [ -f /etc/default/weston ] && $(grep "^OPTARGS" /etc/default/weston | grep -q "use-pixman" ) ;
then
	echo "Without GPU"
	ADDONS="videoconvert ! video/x-raw,format=BGRx ! queue !"
else
	echo "With GPU"
	gpu_presence=1
	ADDONS=""
fi

# Detect size of screen
SCREEN_WIDTH=$(weston-info | grep logical_width | sed -r "s/logical_width: ([0-9]+),.*/\1/")
SCREEN_HEIGHT=$(weston-info | grep logical_width | sed -r "s/.*logical_height: ([0-9]+).*/\1/")

if [ $gpu_presence -eq 0 ] || [ $SCREEN_HEIGHT -lt 480 ];
then
	VIDEO_FILE=/usr/local/demo/media/ST19619_ST_Company_Video_16_9_EN_272p.webm
else
	VIDEO_FILE=/usr/local/demo/media/ST2297_visionv3.webm
fi

echo "Gstreamer graph:"
GRAPH="playbin uri=file://$VIDEO_FILE video-sink=\"$ADDONS waylandsink fullscreen=true\""
echo "   $GRAPH"

pty_exec "$GRAPH"
