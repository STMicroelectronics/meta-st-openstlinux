FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://0001-kmsallocator-Port-to-the-new-DRM-Dumb-Allocator.patch \
    file://0002-gtkwaylandsink-Remove-redefine-of-GST_CAPS_FEATURE_M.patch \
    file://0003-waylandsink-Stop-modifying-the-display-GstVideoInfo.patch \
    file://0004-gtkwaylandsink-Force-a-redraw-on-resolution-change.patch \
    file://0005-waylandsink-Let-the-baseclass-know-when-frames-are-d.patch \
    file://0006-waylandsink-Refactor-internal-pool-handling.patch \
    file://0007-gtkwaylandsink-Fix-display-wl_window-pool-leaks.patch \
    file://0008-wllinuxdmabuf-Handle-video-meta-inside-the-importer.patch \
    file://0009-wlvideoformat-Fix-sign-issue-for-DRM-fourcc.patch \
    file://0010-wlvideobufferpool-Add-DRM-Dumb-buffer-support.patch \
    file://0011-wayladnsink-Add-DRM-Dumb-allocator-support.patch \
    file://0012-bad-Update-doc-cache-for-waylandsink-changes.patch \
    file://0014-WAYLANDSINK-use-card0a-as-default-drm-device.patch \
    file://0015-waylandsink-Uprank-to-secondary.patch \
    file://0016-gstwlshmallocator-correct-WL-API-declaration.patch \
    file://0017-gtkwaylandsink-Destroy-GstWlWindow-when-par.patch \
    file://0018-GTKWAYLANDSINK-use-card0-as-default-drm-device.patch \
    file://0019-waylandsink-Emit-map-signal-boarder-surface-is-ready.patch \
    file://0020-gtkwaylandsink-do-not-use-drm-dumb-pool-with-DMAbuf-.patch \
    file://0022-codecs-Add-base-class-for-stateless-vp8-encoder.patch \
    file://0023-v4l2codecs-Add-V4L2-VP8-stateless-encode-uAPI.patch \
    file://0024-v4l2codecs-Add-v4l2-encoder-class.patch \
    file://0025-v4l2codecs-Add-V4L2-stateless-VP8-encoder.patch \
    file://0026-v4l2codecs-Register-V4L2-stateless-Vp8-encoder.patch \
    file://0027-waylandsink-HACK-disable-frame-dropping-while-redraw.patch \
    file://0028-v4l2codecs-add-key-frame-signaling.patch \
    file://0029-gtkwaylandsink-HACK-disable-frame-dropping-while-red.patch \
    file://0030-gtkwaylandsink-cancel-pending-redraw-callback-on-pau.patch \
    file://0031-v4l2codecs-fix-support-of-unaligned-videos.patch \
"

PACKAGECONFIG_GL ?= "${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'gles2 egl', '', d)}"
PACKAGECONFIG[gtk3] = "-Dgtk3=enabled,-Dgtk3=disabled,gtk+3"

PACKAGECONFIG ?= " \
    ${GSTREAMER_ORC} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez', '', d)} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'directfb vulkan', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland gtk3', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'gl', '', d)} \
    bz2 closedcaption curl dash dtls hls rsvg sbc smoothstreaming sndfile \
    ttml uvch264 webp \
    faac kms \
    v4l2codecs \
"

do_install:append() {
    install -d ${D}${includedir}/gstreamer-1.0/wayland
    install -m 644 ${S}/gst-libs/gst/wayland/wayland.h ${D}${includedir}/gstreamer-1.0/wayland
}
