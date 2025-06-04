#!/bin/sh
function print_debug() {
    echo "[exec]: $@"
}

is_dcmipp_present() {
    DCMIPP_SENSOR="NOTFOUND"
    # on disco board ov5640 camera can be present on csi connector
    for video in $(find /sys/class/video4linux -name "video*" -type l);
    do
        if [ "$(cat $video/name)" = "dcmipp_dump_capture" ]; then
            cd $video/device/
            mediadev=/dev/$(ls -d media*)
            cd -
            for sub in $(find /sys/class/video4linux -name "v4l-subdev*" -type l);
            do
                subdev_name=$(tr -d '\0' < $sub/name | awk '{print $1}')
                if [ "$subdev_name" = "gc2145" ] || [ "$subdev_name" = "ov5640" ]; then
                    DCMIPP_SENSOR=$subdev_name
                    V4L_DEVICE="device=/dev/$(basename $video)"
                    sensorsubdev=$(tr -d '\0' < $sub/name)
                    #bridge is connected to output of sensor (":0 [ENABLED" with media-ctl -p)
                    bridgesubdev=$(media-ctl -d $mediadev -p -e "$sensorsubdev" | grep ":0 \[ENABLED" | awk -F\" '{print $2}')
                    parallelbuscode="RGB565_2X8_LE"
                    echo "media device: "$mediadev
                    echo "video device: "$V4L_DEVICE
                    echo "sensor    subdev: " $sensorsubdev
                    echo "bridge    subdev: " $bridgesubdev

                    return
                fi
            done
        fi
    done
}

is_dcmi_present() {
    DCMI_SENSOR="NOTFOUND"
    # on disco board ov5640 camera can be present on // connector
    for video in $(find /sys/class/video4linux -name "video*" -type l);
    do
        if [ "$(cat $video/name)" = "stm32_dcmi" ]; then
            V4L_DEVICE="device=/dev/$(basename $video)"
            DCMI_SENSOR="$(basename $video)"
            echo "video DCMI device: "$V4L_DEVICE
            return
        fi
    done
}

get_webcam_device() {
    found="NOTFOUND"
    for video in $(find /sys/class/video4linux -name "video*" -type l | sort);
    do
        if [ "$(cat $video/name)" = "dcmipp_dump_capture" ]; then
            found="FOUND"
        else
            V4L_DEVICE="device=/dev/$(basename $video)"
            break;
        fi
    done
}

# ------------------------------
#         main
# ------------------------------

# graphic brackend detection
if [ -f /etc/default/weston ] && $(grep "^OPTARGS" /etc/default/weston | grep -q "use-pixman" ) ;
then
	echo "Without GPU"
	ADDONS="videoconvert ! queue !"
else
	echo "With GPU"
	ADDONS=""
fi


# Detect size of screen
SCREEN_WIDTH=$(wayland-info -i zxdg_output_manager_v1 | grep -A2 "name" | tr '\n' ' ' | sed "s|--|#|g" |tr '#' '\n' | grep -v pipewire | tr '\t' '\n' | grep logical_width | sed -r "s/logical_width: ([0-9]+),.*/\1/")
SCREEN_HEIGHT=$(wayland-info -i zxdg_output_manager_v1 | grep -A2 "name" | tr '\n' ' ' | sed "s|--|#|g" |tr '#' '\n' | grep -v pipewire | tr '\t' '\n' | grep logical_width | sed -r "s/.*logical_height: ([0-9]+).*/\1/")

# camera detection
is_dcmipp_present
if [ "$DCMIPP_SENSOR" != "NOTFOUND" ]; then
    WIDTH=640
    HEIGHT=480

    sensordev=$(media-ctl -d $mediadev -p -e "$sensorsubdev" | grep "node name" | awk -F\name '{print $2}')
    sensorbuscode=`v4l2-ctl --list-subdev-mbus-codes -d $sensordev | grep RGB565 | awk -FMEDIA_BUS_FMT_ '{print $2}'| head -n 1`
    echo "sensor mbus-code: "$sensorbuscode
    print_debug media-ctl -d $mediadev --set-v4l2 "'$sensorsubdev':0[fmt:$sensorbuscode/${WIDTH}x${HEIGHT} field:none]"
    media-ctl -d $mediadev --set-v4l2 "'$sensorsubdev':0[fmt:$sensorbuscode/${WIDTH}x${HEIGHT} field:none]"
    if [ "$bridgesubdev" != "dcmipp_input" ]; then
        print_debug media-ctl -d $mediadev --set-v4l2 "'$bridgesubdev':2[fmt:$sensorbuscode/${WIDTH}x${HEIGHT}]"
        media-ctl -d $mediadev --set-v4l2 "'$bridgesubdev':2[fmt:$sensorbuscode/${WIDTH}x${HEIGHT}]"
    fi
    print_debug media-ctl -d $mediadev --set-v4l2 "'dcmipp_input':1[fmt:$parallelbuscode/${WIDTH}x${HEIGHT}]"
    media-ctl -d $mediadev --set-v4l2 "'dcmipp_input':1[fmt:$parallelbuscode/${WIDTH}x${HEIGHT}]"
    print_debug media-ctl -d $mediadev --set-v4l2 "'dcmipp_dump_postproc':1[fmt:$parallelbuscode/${WIDTH}x${HEIGHT}]"
    media-ctl -d $mediadev --set-v4l2 "'dcmipp_dump_postproc':1[fmt:$parallelbuscode/${WIDTH}x${HEIGHT}]"
    V4L2_CAPS="video/x-raw, format=RGB16, width=$WIDTH, height=$HEIGHT"
    V4L_OPT=""

else
    is_dcmi_present
    if [ "$DCMI_SENSOR" != "NOTFOUND" ]; then
        COMPATIBLE_BOARD=$(tr -d '\0' < /proc/device-tree/compatible | sed "s|st,|,|g" | cut -d ',' -f2 | head -n 1 |tr '\n' ' ' | sed "s/ //g")
        case $COMPATIBLE_BOARD in
        stm32mp15*)
            WIDTH=640
            HEIGHT=480
            ;;
        *)
            WIDTH=640
            HEIGHT=480
            ;;
        esac
    else
        get_webcam_device
        # suppose we have a webcam
        WIDTH=640
        HEIGHT=480
    fi

    V4L2_CAPS="video/x-raw, width=$WIDTH, height=$HEIGHT"
    V4L_OPT="io-mode=4"
    v4l2-ctl --set-parm=30
fi
