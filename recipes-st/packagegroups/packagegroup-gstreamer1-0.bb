DESCRIPTION = "Gstreamer 1.0 components"
LICENSE = "LGPLv2+"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/LGPL-2.0;md5=9427b8ccf5cf3df47c29110424c9641a"

PACKAGE_ARCH = "${TUNE_PKGARCH}"

inherit packagegroup

PACKAGES = "\
    packagegroup-gstreamer1-0 \
    "

PROVIDES = "${PACKAGES}"
RDEPENDS_packagegroup-gstreamer1-0 = "\
    gstreamer1.0-plugins-base-meta \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good-meta \
    gstreamer1.0-plugins-bad-meta \
    gstreamer1.0-plugins-ugly-meta \
    \
    gstreamer1.0-libav \
    gstreamer1.0-rtsp-server-meta \
"
