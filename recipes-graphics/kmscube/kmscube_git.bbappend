FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Pin to commit "kmscube: gears: use only GLES2"
SRCREV = "311eaaaa473d593c30d118799aa19ac4ad53cd65"

SRC_URI += "file://0001-Revert-gst-decoder.c-switch-to-decodebin3.patch"

PACKAGECONFIG = "gstreamer"
DEPENDS += "gstreamer1.0 gstreamer1.0-plugins-base"
