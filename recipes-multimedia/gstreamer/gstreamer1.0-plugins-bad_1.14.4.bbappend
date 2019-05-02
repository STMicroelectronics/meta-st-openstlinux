FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " file://0010-waylandsink-Uprank-to-secondary.patch "
SRC_URI_append = " file://0001-waylandsink-add-I420-to-dmabuf-supported-formats.patch "
SRC_URI_append = " file://0002-waylandsink-add-dmabuf-bufferpool.patch "
SRC_URI_append = " file://0003-waylandsink-fix-error-when-mmapping-dmabuf-buffers.patch "
SRC_URI_append = " file://0004-waylandsink-fix-wrong-width-when-creating-dmabuf-dum.patch "
SRC_URI_append = " file://0005-waylandsink-do-not-hardcode-dmabuf-bufferpool-info-s.patch "
SRC_URI_append = " file://0006-waylandsink-increase-max-buffers-to-32-to-enable-dma.patch "
SRC_URI_append = " file://0007-waylandsink-always-select-dmabuf-buffer-pool.patch "
SRC_URI_append = " file://0008-waylandsink-do-not-destroy-pool-twice.patch "
SRC_URI_append = " file://0009-waylandsink-HACK-disable-frame-dropping-while-redraw.patch "
SRC_URI_append = " file://0011-waylandsink-fullscreen-support.patch "
SRC_URI_append = " file://0012-waylandsink-set-video-alignment-to-32-bytes.patch "
SRC_URI_append = " file://0013-waylandsink-fallback-to-shm-if-display-does-not-supp.patch "

PACKAGECONFIG_GL ?= "${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'gles2 egl', '', d)}"

PACKAGECONFIG ?= " \
    ${GSTREAMER_ORC} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)} \
    bz2 curl dash dtls hls rsvg sbc smoothstreaming sndfile ttml uvch264 webp \
    faac kms \
"

#do_configure_prepend() {
#    ${S}/autogen.sh --noconfigure
#}

do_install_append() {
    install -d ${D}${libdir}/pkgconfig ${D}${includedir}/gstreamer-1.0/wayland
    install -m 644 ${B}/pkgconfig/gstreamer-wayland.pc ${D}${libdir}/pkgconfig/gstreamer-wayland-1.0.pc
    install -m 644 ${S}/gst-libs/gst/wayland/wayland.h ${D}${includedir}/gstreamer-1.0/wayland
}
