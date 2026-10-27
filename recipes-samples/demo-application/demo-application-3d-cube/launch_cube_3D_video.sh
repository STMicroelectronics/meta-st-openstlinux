#!/bin/sh
DRM_RENDERER=""
if [ -d /sys/class/drm/card1 ]; then
    if $(cat /sys/class/drm/card1/device/modalias | grep -q "display-controller") ; then
        DRM_RENDERER="-d /dev/dri/card1"
    fi
fi

/usr/local/demo/bin/weston-st-egl-cube-tex $DRM_RENDERER --video=/usr/local/demo/media/ST2297_visionv3.webm -f 

