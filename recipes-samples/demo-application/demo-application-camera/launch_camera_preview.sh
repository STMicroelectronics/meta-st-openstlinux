#!/bin/sh
v4l2-ctl --set-parm=20

# get screen size
SCREEN_WIDTH=$(weston-info | grep logical_width | sed -r "s/logical_width: ([0-9]+),.*/\1/")
SCREEN_HEIGHT=$(weston-info | grep logical_width | sed -r "s/.*logical_height: ([0-9]+).*/\1/")

if [ $SCREEN_HEIGHT -ge 480 ];
then
	WIDTH=640
	HEIGHT=480
else
	WIDTH=424
	HEIGHT=240
fi
if [ -f /etc/default/weston ] && $(grep "^OPTARGS" /etc/default/weston | grep -q "use-pixman" ) ;
then
	echo "Without GPU"
	ADDONS="videoconvert ! queue !"
else
	echo "With GPU"
	ADDONS=""
fi
/usr/local/demo/bin/touch-event-gtk-player --graph "v4l2src io-mode=4 ! video/x-raw,width=$WIDTH,height=$HEIGHT ! queue ! $ADDONS waylandsink fullscreen=true" 2> /dev/null > /dev/null
