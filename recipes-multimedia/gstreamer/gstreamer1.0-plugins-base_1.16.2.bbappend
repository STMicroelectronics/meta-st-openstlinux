FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/:"

SRC_URI_append = " file://0001-playbin2-disable-any-default-video-processing.patch "
SRC_URI_append = " file://0002-playbin3-disable-any-default-video-processing.patch "

PACKAGECONFIG ?= " \
    ${GSTREAMER_ORC} \
    ${PACKAGECONFIG_GL} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'alsa x11', d)} \
    jpeg ogg pango png theora vorbis \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland egl', '', d)} \
    encoding \
"

PACKAGECONFIG[encoding]    = "-Dencoding=enabled,-Dencoding=disabled,"

#enable hardware convert/scale in playbin (gstsubtitleoverlay.c, gstplaysinkvideoconvert.c, gstplaysink.c) & gstencodebin (gstencodebin.c)
#disable software convert/scale/rate in gstencodebin (gstencodebin.c)
#HW_TRANSFORM_CONFIG = 'CFLAGS="-DCOLORSPACE=\\\\\\"autovideoconvert\\\\\\" \
#                               -DCOLORSPACE_SUBT=\\\\\\"videoconvert\\\\\\" \
#                               -DGST_PLAYBIN_DEFAULT_FLAGS=0x00000017 \
#                               -DCOLORSPACE2=\\\\\\"identity\\\\\\" \
#                               -DVIDEOSCALE=\\\\\\"identity\\\\\\" \
#                               -DVIDEORATE=\\\\\\"identity\\\\\\" "'

#CACHED_CONFIGUREVARS += "${@bb.utils.contains('DISTRO_FEATURES', 'hwdecode', '${HW_TRANSFORM_CONFIG}', '', d)}"

