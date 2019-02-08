#!/bin/sh

chown -R root:root /home/root
dbusinfo=( $(dbus-launch) )
DBUS_SESSION_BUS_ADDRESS=${dbusinfo[0]#DBUS_SESSION_BUS_ADDRESS=}
DBUS_SESSION_BUS_PID=${dbusinfo[1]#DBUS_SESSION_BUS_PID=}
PULSE_RUNTIME_PATH=/var/run/pulse

export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID
export PULSE_RUNTIME_PATH
