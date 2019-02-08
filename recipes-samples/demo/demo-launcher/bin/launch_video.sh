#!/bin/sh
gst-launch-1.0 playbin uri=file:///usr/local/demo/media/ST2297_visionv3.webm video-sink="waylandsink" &
