#!/bin/sh

cmd() {
    cmd=$1
    echo "$cmd"
    eval "$cmd" > /dev/null 2>&1
}

# DCMIPP bus info
DCMIPP_MEDIA="platform:48030000.dcmipp"

get_webcam_device() {
    for video in $(find /sys/class/video4linux -name "video*" -type l | sort);
    do
        if [ "$(cat "$video/name")" != "dcmipp_main_capture" ]; then
            V4L_DEVICE="device=/dev/$(basename "$video")"
            break;
        fi
    done
}

config_dcmipp_media_ctl() {
    width=$1
    height=$2
    fps=$3

    # Starting from the dcmipp_input go down until the first source subdev
    current_subdev="dcmipp_input"
    source_subdev="dcmipp_input"
    while [ -n "$source_subdev" ]; do
        source_subdev=$(media-ctl -d $DCMIPP_MEDIA -p -e "$current_subdev" | grep '<-' | grep -v 'dcmipp_tpg' | awk -F\" '{print $2}')
        if [ -n "$source_subdev" ]; then
            current_subdev=$source_subdev
        fi
    done
    sensor_subdev=$current_subdev
    sensor_dev=$(media-ctl -d $DCMIPP_MEDIA -e "$sensor_subdev")
    bridge_subdev=$(media-ctl -d $DCMIPP_MEDIA -p -e "$sensor_subdev" | grep '\->' | awk -F\" '{print $2}')
    if [ "$bridge_subdev" = "dcmipp_input" ]; then
        bridge_subdev=""
    else
        bridge_dev=$(media-ctl -d $DCMIPP_MEDIA -e "$bridge_subdev")
    fi
    echo "sensor_subdev=$sensor_subdev"
    echo "sensor_dev=$sensor_dev"
    if [ "$bridge_subdev" != "" ]; then
        echo "bridge_subdev=$bridge_subdev"
        echo "bridge_dev=$bridge_dev"
    fi

    #Use sensor in raw-bayer format
    sensorbuscode=$(v4l2-ctl --list-subdev-mbus-codes -d "$sensor_dev" | grep SRGGB10 | awk -FMEDIA_BUS_FMT_ '{print $2}')
    echo "sensorbuscode=$sensorbuscode"

    SENSORWIDTH=0
    SENSORHEIGHT=0
    case "$sensor_subdev" in
        *"ov5640"*)
            #OV5640 only support 720p with raw-bayer format
            SENSORWIDTH=1280
            SENSORHEIGHT=720
            #OV5640 claims to support all raw bayer combinations but always output SBGGR8_1X8...
            sensorbuscode=SBGGR8_1X8
            ;;
        *"imx335"*)
            #IMX335 expose both RGGB10 and RGGB12 however only RGGB10 can work on CSI 2 lanes
            sensorbuscode=SRGGB10_1X10
            main_postproc=$(media-ctl -d $DCMIPP_MEDIA -e dcmipp_main_postproc)

            #Enable gamma correction
            v4l2-ctl -d "$main_postproc" -c gamma_correction=1
            #Do exposure correction continuously in background
            sleep 3  && while : ; do /usr/local/demo/bin/dcmipp-isp-ctrl -i0 -g > /dev/null ; done &
            ;;
    esac

    #Let sensor return its prefered resolution & format
    media-ctl -d $DCMIPP_MEDIA --set-v4l2 "'$sensor_subdev':0[fmt:$sensorbuscode/${SENSORWIDTH}x${SENSORHEIGHT}@1/${fps} field:none]" > /dev/null 2>&1
    sensorfmt=$(media-ctl -d $DCMIPP_MEDIA --get-v4l2 "'$sensor_subdev':0" | awk -F"fmt:" '{print $2}' | awk -F" " '{print $1}')
    SENSORWIDTH=$(echo "$sensorfmt" | awk -F"/" '{print $2}' | awk -F"x" '{print $1}')
    SENSORHEIGHT=$(echo "$sensorfmt" | awk -F"/" '{print $2}' | awk -F"x" '{print $2}' | awk -F" " '{print $1}' | awk -F"@" '{print $1}')
    echo "SENSORWIDTH=$SENSORWIDTH"
    echo "SENSORHEIGHT=$SENSORHEIGHT"

    #Use main pipe for debayering, scaling and color conversion
    echo "Mediacontroller graph:"
    cmd "  media-ctl -d $DCMIPP_MEDIA -l \"'dcmipp_input':1->'dcmipp_dump_postproc':0[0]\""
    cmd "  media-ctl -d $DCMIPP_MEDIA -l \"'dcmipp_input':2->'dcmipp_main_isp':0[1]\""
    cmd "  media-ctl -d $DCMIPP_MEDIA --set-v4l2 \"'$sensor_subdev':0[fmt:$sensorbuscode/${SENSORWIDTH}x${SENSORHEIGHT}]\""
    if [ "$bridge_subdev" != "" ]; then
        cmd "  media-ctl -d $DCMIPP_MEDIA --set-v4l2 \"'$bridge_subdev':1[fmt:$sensorbuscode/${SENSORWIDTH}x${SENSORHEIGHT}]\""
    fi
    cmd "  media-ctl -d $DCMIPP_MEDIA --set-v4l2 \"'dcmipp_input':2[fmt:$sensorbuscode/${SENSORWIDTH}x${SENSORHEIGHT}]\""
    cmd "  media-ctl -d $DCMIPP_MEDIA --set-v4l2 \"'dcmipp_main_isp':1[fmt:RGB888_1X24/${SENSORWIDTH}x${SENSORHEIGHT} field:none]\""
    cmd "  media-ctl -d $DCMIPP_MEDIA --set-v4l2 \"'dcmipp_main_postproc':0[compose:(0,0)/${width}x${height}]\""
    echo ""
}

# ------------------------------
#         main
# ------------------------------

# graphic backend detection
if [ -f /etc/default/weston ] && $(grep "^OPTARGS" /etc/default/weston | grep -q "use-pixman" ) ;
then
	echo "Without GPU"
	ADDONS="videoconvert ! queue !"
else
	echo "With GPU"
	ADDONS=""
fi

WIDTH=640
HEIGHT=480
FPS=30
FMT=RGB16

# Check if dcmipp is available
if media-ctl -d $DCMIPP_MEDIA > /dev/null 2>&1; then
    comp_board=$(tr -d '\0' < /proc/device-tree/compatible | sed "s|^st,|;|" | cut -d';' -f2 | head -n 1 |tr '\n' ' ' | sed "s/ //g")
    # for the time being, libcamera is only enabled on MP25-EVAL & MP25-DK
    if $(echo $comp_board | grep -qG "stm32mp2[0-9]*[abcdef]-ev1") || $(echo $comp_board | grep -qG "stm32mp2[0-9]*[abcdef]-dk") ; then
        GST_SOURCE="libcamerasrc name=cs src::stream-role=view-finder cs.src"
    else
        config_dcmipp_media_ctl $WIDTH $HEIGHT $FPS
        V4L_DEVICE="device=$(media-ctl -d $DCMIPP_MEDIA -e "dcmipp_main_capture")"
        V4L_OPT=""
        GST_SOURCE="v4l2src $V4L_DEVICE $V4L_OPT"
    fi
    GST_CAPS="video/x-raw, format=$FMT, width=$WIDTH, height=$HEIGHT"
else
    get_webcam_device
    # suppose we have a webcam
    V4L_OPT="io-mode=4"
    GST_SOURCE="v4l2src $V4L_DEVICE $V4L_OPT"
    GST_CAPS="video/x-raw, width=$WIDTH, height=$HEIGHT"
    v4l2-ctl --set-parm=20
fi

# Detect size of screen
SCREEN_WIDTH=$(wayland-info -i zxdg_output_manager_v1 | grep -A2 "name" | tr '\n' ' ' | sed "s|--|#|g" |tr '#' '\n' | grep -v pipewire | tr '\t' '\n' | grep logical_width | sed -r "s/logical_width: ([0-9]+),.*/\1/")
SCREEN_HEIGHT=$(wayland-info -i zxdg_output_manager_v1 | grep -A2 "name" | tr '\n' ' ' | sed "s|--|#|g" |tr '#' '\n' | grep -v pipewire | tr '\t' '\n' | grep logical_width | sed -r "s/.*logical_height: ([0-9]+).*/\1/")
echo "SCREEN_WIDTH=$SCREEN_WIDTH"
echo "SCREEN_HEIGHT=$SCREEN_HEIGHT"
