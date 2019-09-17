#!/bin/sh
# found card
cards=`pacmd list-cards |  egrep -i 'alsa.card_name' | sed 's/ //g'| sed 's/alsa.card_name=\"//g'| sed 's/\"//g'`
index=0
for i in $cards;
do
	found=`echo $i | grep -n STM32MP | wc -l`
	if [ $found -eq 0  ];
	then
		pacmd set-card-profile $index output:analog-stereo
	fi
	index=$((index+1))
done

/usr/local/demo/demo_launcher.py
