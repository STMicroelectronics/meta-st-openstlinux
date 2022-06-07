SUMMARY = "Gstreamer 1.0 components"
LICENSE = "LGPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/LGPL-2.0-or-later;md5=6d2d9952d88b50a51a5c73dc431d06c7"

PACKAGE_ARCH = "${TUNE_PKGARCH}"

inherit packagegroup

PACKAGES = "\
    packagegroup-gstreamer1-0 \
    "

PROVIDES = "${PACKAGES}"
RDEPENDS:packagegroup-gstreamer1-0 = "\
    gstreamer1.0-plugins-base-meta \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good-meta \
    gstreamer1.0-plugins-bad-meta \
    gstreamer1.0-plugins-ugly-meta \
    \
    gstreamer1.0-libav \
    gstreamer1.0-rtsp-server-meta \
"
