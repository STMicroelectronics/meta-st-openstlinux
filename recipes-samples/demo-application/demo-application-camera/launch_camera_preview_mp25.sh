#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/launch_camera_control_mp25.sh

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

if [ -n "$GST_SOURCE" ]; then
	echo "GStreamer graph:"
	GRAPH="$GST_SOURCE ! $GST_CAPS ! queue ! $ADDONS gtkwaylandsink name=gtkwsink"

	echo "  $GRAPH"
	pty_exec "$GRAPH"

	#Kill exposure correction background task
	killall launch_camera_control_mp25.sh
	killall launch_camera_preview_mp25.sh
else
	echo "WARNING: no camera supported detected by this script"
fi

