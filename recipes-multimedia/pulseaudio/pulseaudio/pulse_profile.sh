#!/bin/sh

chown -R root:root /home/root
dbusinfo=$(dbus-launch)
DBUS_SESSION_BUS_ADDRESS=$(dbus-launch |grep DBUS_SESSION_BUS_ADDRESS| cut -d'=' -f 2-)
DBUS_SESSION_BUS_PID=$(dbus-launch |grep DBUS_SESSION_BUS_PID |cut -d'=' -f2)
PULSE_RUNTIME_PATH=/var/run/pulse

export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID
export PULSE_RUNTIME_PATH
