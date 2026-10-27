#!/bin/sh -

pactl set-default-sink $(pactl list sinks| grep -E "Sink #|Name" | grep bluez -B1 | grep "Sink #" |awk '{print $2 }' | sed "s|#||")



