#!/bin/sh
#gst-launch-1.0 playbin uri=file:///usr/local/demo/media/ST2297_visionv3.webm video-sink="waylandsink"
/usr/local/demo/bin/touch-event-gtk-player -F file:///usr/local/demo/media/ST2297_visionv3.webm 2> /dev/null > /dev/null
