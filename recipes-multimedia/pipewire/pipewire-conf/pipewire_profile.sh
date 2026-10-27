#!/bin/sh

# NOTE: thos profile must be sources by weston
# to be sure to catch pipewire context.
#
# `id -u weston` = 1000
PIPEWIRE_CORE=/run/user/1000/pipewire-0
PIPEWIRE_RUNTIME_DIR=/run/user/1000/

export PIPEWIRE_CORE PIPEWIRE_RUNTIME_DIR
