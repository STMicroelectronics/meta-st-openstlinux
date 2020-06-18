#!/bin/sh
v4l2-ctl --set-parm=20
/usr/local/demo/bin/touch-event-gtk-player --graph "v4l2src io-mode=4 ! video/x-raw,width=640,height=480 ! queue ! waylandsink fullscreen=true" 2> /dev/null > /dev/null
