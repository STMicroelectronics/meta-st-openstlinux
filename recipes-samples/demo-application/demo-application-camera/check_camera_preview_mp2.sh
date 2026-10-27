#!/bin/sh

is_dcmipp_present() {
    DCMIPP_SENSOR="NOTFOUND"
    if [ $(find /sys/class/video4linux/ -name v4l-subdev* 2>/dev/null | wc -l) -gt 0 ] ; then
        # check if dcmipp is present and a camera is present
        if $(cat /sys/class/video4linux/video*/device/modalias | grep -q dcmi) ; then
            if ! $(cat /sys/class/video4linux/v4l-subdev*/device/modalias | grep -q camera) ; then
                # not camera available via dmicpp
                return
            fi
        fi
    else
        # not camera available via subdev
        return
    fi
    # on disco board ov5640 camera can be present on csi connector
    for video in $(find /sys/class/video4linux -name "video*" -type l);
    do
        if [ "$(cat $video/name)" = "dcmipp_main_capture" ]; then
            cd $video/device/
            mediadev=/dev/$(ls -d media*)
            cd -
            for sub in $(find /sys/class/video4linux -name "v4l-subdev*" -type l);
            do
                subdev_name=$(tr -d '\0' < $sub/name | awk '{print $1}')
                #HFR FIXME get rid of driver name
                if [ "$subdev_name" = "gc2145" ] || [ "$subdev_name" = "ov5640" ] || [ "$subdev_name" = "imx335" ]; then
                    DCMIPP_SENSOR=$subdev_name
                    V4L_DEVICE="device=/dev/$(basename $video)"
                    sensorsubdev="$(tr -d '\0' < $sub/name)"
                    sensordev=$(media-ctl -d $mediadev -p -e "$sensorsubdev" | grep "node name" | awk -F\name '{print $2}')
                    #interface is connected to input of isp (":1 [ENABLED" with media-ctl -p)
                    interfacesubdev=$(media-ctl -d $mediadev -p -e "dcmipp_main_isp" | grep ":1 \[ENABLED" | awk -F\" '{print $2}')
                    echo "mediadev="$mediadev
                    echo "sensorsubdev=\""$sensorsubdev\"
                    echo "sensordev="$sensordev
                    echo "interfacesubdev="$interfacesubdev

                    return
                fi
            done
        fi
    done
}

get_webcam_device() {
    WEBCAM_found="NOTFOUND"
    for video in $(find /sys/class/video4linux -name "video*" -type l | sort);
    do
        if [  $(cat $video/name | grep -q "dcmi";echo $?) -ne 0 ] &&  [ $(cat $video/name | grep -q "stm";echo $?) -ne 0 ]; then
            WEBCAM_found="FOUND"
            break;
        fi
    done
}

# ------------------------------
#         main
# ------------------------------

# camera detection
# detect if we have a gc2145 or ov5640 plugged and associated to dcmipp
is_dcmipp_present
if [ "$DCMIPP_SENSOR" != "NOTFOUND" ]; then
    exit 0
fi
get_webcam_device
if [ "$WEBCAM_found" = "FOUND" ]; then
    exit 0
fi
exit 1
