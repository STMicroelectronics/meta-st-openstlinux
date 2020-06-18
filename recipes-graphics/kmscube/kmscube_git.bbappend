FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG = "gstreamer"
DEPENDS += "gstreamer1.0 gstreamer1.0-plugins-base"

SRC_URI_append += " file://0001-fix-gbm_bo_map-detection.patch "
SRC_URI_append += " file://0001-Disable-Texturator.patch "
SRC_URI_append += " file://0002-fix-gbm_bo_map-detection-for-MESON.patch "


