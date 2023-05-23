#!/bin/sh

case $1 in
start)
   systemctl --user start pulseaudio
   /bin/sleep 5
   /usr/bin/psplash-drm-quit
   ;;
stop)
   systemctl --user stop weston.service weston.socket
   systemctl --user stop pulseaudio
   ;;
*)
    echo "Help: $0 [start|stop]"
    ;;
esac
