#!/bin/sh

DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/`id -u weston`/bus

export DBUS_SESSION_BUS_ADDRESS

