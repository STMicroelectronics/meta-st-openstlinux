#!/bin/sh -
source /etc/default/default_audio_profile
PROFILE_LOCAL=$DEFAULT_AUDIO_LOCAL_PROFILE
PROFILE_HDMI=$DEFAULT_AUDIO_HDMI_PROFILE
#HDMI_STATUS=$(cat /sys/class/drm/card0/*HDMI*/status)
HDMI_STATUS=$(modetest | grep HDMI | awk -F ' ' '{print $3}')

if [ "$HDMI_STATUS" = "connected" ]; then
  PROFILE=$PROFILE_HDMI
else
  PROFILE=$PROFILE_LOCAL
fi
if [ "$USER" == "weston" ]; then
    script -qc "/usr/bin/st_pipewire_switch.sh $PROFILE"
else
    script -qc "su -l weston -c /usr/bin/st_pipewire_switch.sh $PROFILE"
fi
