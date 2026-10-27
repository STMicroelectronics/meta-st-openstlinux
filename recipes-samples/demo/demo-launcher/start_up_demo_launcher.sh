#!/bin/sh
DEFAULT_DEMO_APPLICATION_GTK=/usr/local/demo/launch-demo-gtk.sh
if [ -e /etc/default/demo-launcher ]; then
    source /etc/default/demo-launcher
    if [ ! -z "$DEFAULT_DEMO_APPLICATION" ]; then
        script -qc "$DEFAULT_DEMO_APPLICATION"
    else
        script -qc "$DEFAULT_DEMO_APPLICATION_GTK"
    fi
else
    script -qc "$DEFAULT_DEMO_APPLICATION_GTK"
fi
