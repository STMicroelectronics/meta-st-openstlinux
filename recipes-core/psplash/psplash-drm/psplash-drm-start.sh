#!/bin/sh -

# List of Splash screen available
SPLASH_BG_LANDSCAPE_INDUS_480_272="/usr/share/splashscreen/ST30739_splash-480x272.png"
SPLASH_BG_LANDSCAPE_INDUS_480_800="/usr/share/splashscreen/ST30739_splash-800x480.png"
SPLASH_BG_LANDSCAPE_INDUS_800_480="/usr/share/splashscreen/ST30739_splash-800x480.png"
SPLASH_BG_LANDSCAPE_INDUS_1280_720="/usr/share/splashscreen/ST30739_splash-1280x720.png"

SPLASH_BG_LANDSCAPE_TSN_1024_600="/usr/share/splashscreen/ST30739_splash-1024x600.png"
SPLASH_BG_LANDSCAPE_TSN_1920_1080="/usr/share/splashscreen/ST30739_splash-1920x1080.png"
SPLASH_BG_PORTRAIT_TSN_720_1280="/usr/share/splashscreen/ST30739_splash-720x1280.png"

DEFAULT_SPLASH=$SPLASH_BG_LANDSCAPE_INDUS_480_800
OPT=""
if [ -d /proc/device-tree/ ]; then
	echo "[DEBUG]: test compatible"
	# stm32mp13: 480x272 screen (landscape)
	if $(cat /proc/device-tree/compatible | grep -q "stm32mp13")
	then
		DEFAULT_SPLASH=$SPLASH_BG_LANDSCAPE_INDUS_480_272
		echo "[DEBUG]: compatible mp13"
	fi
	if $(cat /proc/device-tree/compatible | grep -q "stm32mp21")
	then
		DEFAULT_SPLASH=$SPLASH_BG_LANDSCAPE_INDUS_480_272
		echo "[DEBUG]: compatible mp21"
	fi
	# stm32mp15: 480x800 or 1280x720 (landscape) + HDMI 1280x720
	if  $(cat /proc/device-tree/compatible | grep -q "stm32mp15")
	then
		DEFAULT_SPLASH=$SPLASH_BG_LANDSCAPE_INDUS_800_480
		echo "[DEBUG]: compatible mp15"
		if [ -e /sys/class/drm/card0-HDMI-A-1/status ]; then
			hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
		else
			if [ -e /sys/class/drm/card1-HDMI-A-1/status ]; then
				hdmi_status=$(cat /sys/class/drm/card1-HDMI-A-1/status)
			else
				hdmi_status=unknown
			fi
		fi
		if [ "$hdmi_status" = "connected" ]; then
			DEFAULT_SPLASH=$SPLASH_BG_LANDSCAPE_INDUS_1280_720
		        OPT="$OPT --force-hdmi"
			echo "[DEBUG]: compatible mp15 with hdmi connected"
		fi
	fi
	# stm32mp25: 1024x600 or 1920x1080 (landscape) + HDMI 1280x720 or 1920x1080
	if  $(cat /proc/device-tree/compatible | grep -q "stm32mp2[35]")
	then
		DEFAULT_SPLASH=$SPLASH_BG_LANDSCAPE_TSN_1024_600
		hdmi_status=$(modetest | grep HDMI | awk -F ' ' '{print $3}')
		lvds_status=$(cat /proc/device-tree/panel-lvds/status)
		echo "[DEBUG]: compatible mp25/mp23"
		echo "[DEBUG]: hdmi status: $hdmi_status"
		echo "[DEBUG]: lvds status: $lvds_status"

		OPT="--force-no-hdmi"
		if [ -e  /proc/device-tree/panel-lvds ] && [ "$lvds_status" = "okay" ]; then
			panel_lvds=$(cat /proc/device-tree/panel-lvds/compatible)
			if $(cat /proc/device-tree/panel-lvds/compatible | grep -q "etml0700z8dh" )
			then
				DEFAULT_SPLASH=$SPLASH_BG_LANDSCAPE_TSN_1920_1080
			else
				DEFAULT_SPLASH=$SPLASH_BG_LANDSCAPE_TSN_1024_600
				if [ -d /usr/local/splashscreen/animated ] ; then
					DEFAULT_SPLASH=/usr/local/splashscreen/animated/splashscreen-animated_%05d.png
					OPT="$OPT --framerate 20 -n 50  -l"
				fi
			fi
		fi
		if [ "$hdmi_status" = "connected" ]; then
			if [ "$lvds_status" = "disabled" ]; then
				OPT=" --maxsize=1920 --force-hdmi"
				DEFAULT_SPLASH=$SPLASH_BG_LANDSCAPE_TSN_1920_1080
				echo "[DEBUG]: compatible mp25 with hdmi connected"
			fi
		fi
		if [ "$hdmi_status" = "disconnected" ] || [ "$hdmi_status" = "unknown" ]; then
			if [ "$lvds_status" = "disabled" ]; then
				exit 1;
			fi
		fi

	fi
fi
echo "/usr/bin/psplash-drm -w $OPT --background 03234b --filename=$DEFAULT_SPLASH"
/usr/bin/psplash-drm -w $OPT --background 03234b --filename=$DEFAULT_SPLASH
