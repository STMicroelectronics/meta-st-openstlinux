#!/bin/sh -
source /etc/default/pulseaudio_profile
PROFILE_LOCAL=$DEFAULT_PULSE_AUDIO_LOCAL_PROFILE
PROFILE_HDMI=$DEFAULT_PULSE_AUDIO_HDMI_PROFILE
HDMI_STATUS=$(cat /sys/class/drm/card0/*HDMI*/status)

if [ "$HDMI_STATUS" = "connected" ]; then
  PROFILE=$PROFILE_HDMI
else
  PROFILE=$PROFILE_LOCAL
fi
cat > /tmp/pulse_temp_switch.sh <<EOF
#!/bin/sh
cards=\$(pactl list cards |  egrep -i 'Card #' | sed 's/Card //g')
index=0
for i in \$cards;
do
    card_info=\$(pactl list cards | grep "Card \$i" -A15 |  grep "alsa.card_name" | sed 's/ //g'| sed 's/alsa.card_name=\"//g'| sed 's/\"//g' | tr '\t' ' ' | sed 's/^\s*//g')
    echo "\$i \$card_info"
    # for each card, search alsa.card_name
    found=\$(echo \$card_info | grep -n STM32MP | wc -l)
    if [ \$found -eq 1 ];
    then
        echo "pactl set-card-profile \$index $PROFILE"
        pactl set-card-profile \$index $PROFILE
        break;
    fi
    index=\$((index+1))
done
EOF
chmod +x /tmp/pulse_temp_switch.sh
if [ "$USER" == "weston" ]; then
    script -qc "/tmp/pulse_temp_switch.sh"
else
    script -qc "su -l weston -c /tmp/pulse_temp_switch.sh"
fi

rm -f /tmp/pulse_temp_switch.sh

