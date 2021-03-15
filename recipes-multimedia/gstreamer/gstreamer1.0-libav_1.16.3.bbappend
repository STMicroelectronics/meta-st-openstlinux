FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " file://0002-gstreamer1.0-libav-disable-decoder-direct-rendering-.patch "
