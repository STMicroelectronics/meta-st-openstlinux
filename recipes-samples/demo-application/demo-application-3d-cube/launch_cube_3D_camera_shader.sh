#!/bin/sh
DRM_RENDERER=""
if [ -d /sys/class/drm/card1 ]; then
    if $(cat /sys/class/drm/card1/device/modalias | grep -q "display-controller") ; then
        DRM_RENDERER="-d /dev/dri/card1"
    fi
fi

if v4l2-ctl -d /dev/video0 -D > /dev/null 2>&1
then
        printf "Video present and "
        if fuser /dev/video0 > /dev/null 2>&1
        then
                printf '%s\n' "device in use"
        else
                printf '%s\n' "device available"
               /usr/local/demo/bin/weston-st-egl-cube-tex -v /dev/video0 -f -a
        fi
else
        printf "Video not present\n"
        /usr/local/demo/bin/weston-st-egl-cube-tex $DRM_RENDERER -3 /usr/local/demo/application/3d-cube/pictures/ST13028_Linux_picto_13.png /usr/local/demo/application/3d-cube/pictures/ST4439_ST_logo.png /usr/local/demo/application/3d-cube/pictures/ST20578_Label_OpenSTlinux_V.png -f -a
fi
