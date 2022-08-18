FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://0001-gstreamer1.0-libav-disable-decoder-direct-rendering-.patch "
