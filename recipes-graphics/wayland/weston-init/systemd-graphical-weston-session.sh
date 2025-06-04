#!/bin/sh

case $1 in
start)
   systemctl --user start pipewire
   systemctl --user start pipewire-pulse
   systemctl --user start wireplumber.service
   /bin/sleep 5
   if [ -e /usr/bin/psplash-drm-quit ]; then
        /usr/bin/psplash-drm-quit
   fi
   ;;
stop)
   systemctl --user stop weston.service weston.socket
   systemctl --user stop wireplumber.service
   systemctl --user stop pipewire-pulse.service pipewire-pulse.socket
   systemctl --user stop pipewire.service pipewire.socket
   ;;
*)
    echo "Help: $0 [start|stop]"
    ;;
esac
