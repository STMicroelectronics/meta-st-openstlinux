FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/:"

SRC_URI:append = " \
    file://0002-DRAFT-video-Allow-frame-copy-from-different-dimensio.patch \
    "

PACKAGECONFIG ?= " \
    ${GSTREAMER_ORC} \
    ${PACKAGECONFIG_GL} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'alsa x11', d)} \
    jpeg ogg pango png theora vorbis \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland egl', '', d)} \
    encoding \
"

PACKAGECONFIG[encoding]    = "-Dencoding=enabled,-Dencoding=disabled,"
