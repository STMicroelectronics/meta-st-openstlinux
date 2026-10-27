#!/bin/sh -
if [ -e /dev/galcore ]; then
	return 0
fi
if [ -e /dev/dri/renderD128 ]; then
	return 0
fi
return 1
