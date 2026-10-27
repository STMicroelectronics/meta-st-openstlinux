#!/bin/sh

PULSE_RUNTIME_PATH=/run/user/`id -u weston`
PULSE_SERVER="unix:/run/user/`id -u weston`/pulse/native"

export PULSE_RUNTIME_PATH
export PULSE_SERVER
