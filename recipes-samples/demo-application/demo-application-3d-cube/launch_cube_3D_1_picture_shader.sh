#!/bin/sh
DRM_RENDERER=""
if [ -d /sys/class/drm/card1 ]; then
    if $(cat /sys/class/drm/card1/device/modalias | grep -q "display-controller") ; then
        DRM_RENDERER="-d /dev/dri/card1"
    fi
fi
/usr/local/demo/bin/weston-st-egl-cube-tex $DRM_RENDERER -1 /usr/local/demo/application/3d-cube/pictures/ST20578_Label_OpenSTlinux_V.png -f -a

