FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://0001-waylandsink-add-I420-to-dmabuf-supported-formats.patch \
    file://0002-waylandsink-add-dmabuf-bufferpool.patch \
    file://0003-waylandsink-fix-error-when-mmapping-dmabuf-buffers.patch \
    file://0004-waylandsink-fix-wrong-width-when-creating-dmabuf-dum.patch \
    file://0005-waylandsink-do-not-hardcode-dmabuf-bufferpool-info-s.patch \
    file://0006-waylandsink-increase-max-buffers-to-32-to-enable-dma.patch \
    file://0007-waylandsink-always-select-dmabuf-buffer-pool.patch \
    file://0008-waylandsink-do-not-destroy-pool-twice.patch \
    file://0009-waylandsink-HACK-disable-frame-dropping-while-redraw.patch \
    file://0010-waylandsink-Uprank-to-secondary.patch \
    file://0011-waylandsink-set-video-alignment-to-32-bytes.patch \
    file://0012-waylandsink-fallback-to-shm-if-display-does-not-supp.patch \
    file://0013-waylandsink-XDG-protocol-does-not-work-in-fullscreen.patch \
    file://0014-waylandsink-silently-drop-erroneous-frame.patch \
    file://0015-waylandsink-add-waylandpool-on-meson-build.patch \
    "

PACKAGECONFIG_GL ?= "${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'gles2 egl', '', d)}"

PACKAGECONFIG ?= " \
    ${GSTREAMER_ORC} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)} \
    bz2 curl dash dtls hls rsvg sbc smoothstreaming sndfile ttml uvch264 webp \
    faac kms \
"

do_install_append() {
    install -d ${D}${includedir}/gstreamer-1.0/wayland
    install -m 644 ${S}/gst-libs/gst/wayland/wayland.h ${D}${includedir}/gstreamer-1.0/wayland
}
