#!/bin/sh
#gst-launch-1.0 playbin uri=file:///usr/local/demo/media/ST2297_visionv3.webm video-sink="waylandsink"
if [ -f /etc/default/weston ] && $(grep "^OPTARGS" /etc/default/weston | grep -q "use-pixman" ) ;
then
	echo "Without GPU"
	ADDONS="videoconvert ! queue !"
else
	echo "With GPU"
	ADDONS=""
fi
#/usr/local/demo/bin/touch-event-gtk-player -F file:///usr/local/demo/media/ST2297_visionv3.webm 2> /dev/null > /dev/null
/usr/local/demo/bin/touch-event-gtk-player --graph "playbin uri=file:///usr/local/demo/media/ST2297_visionv3.webm video-sink='$ADDONS waylandsink fullscreen=true' " 2> /dev/null > /dev/null


