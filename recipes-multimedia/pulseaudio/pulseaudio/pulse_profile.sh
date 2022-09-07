#!/bin/sh

DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/`id -u weston`/bus
PULSE_RUNTIME_PATH=/run/user/`id -u weston`
PULSE_SERVER="unix:/run/user/`id -u weston`/pulse/native"

export DBUS_SESSION_BUS_ADDRESS
export PULSE_RUNTIME_PATH
export PULSE_SERVER
