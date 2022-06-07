FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG = "gstreamer"
DEPENDS += "gstreamer1.0 gstreamer1.0-plugins-base"

SRC_URI:append:stm32mp1common = " file://0001-Add-OpenGLESv3-support.patch "


