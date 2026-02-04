#!/bin/sh
source /etc/profile.d/weston_profile.sh
source /etc/profile.d/pulse_profile.sh

# options:
# --log_level=3 : display log with level 3
# --extra_space=1 : add extra space on top of icon
# --extra_space=2 : add extra space on bottom of icon
# --no_exit_button=1 : remove exit button

/usr/local/demo/demo_launcher.py

# demo: extra space on top, no exit button
#/usr/local/demo/demo_launcher.py --extra_space=1 --no_exit_button=1
