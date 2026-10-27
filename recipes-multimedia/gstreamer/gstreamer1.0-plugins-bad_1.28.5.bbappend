FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://0001-WAYLANDSINK-use-card0a-as-default-drm-device.patch \
    file://0002-waylandsink-Uprank-to-secondary.patch \
    file://0003-GTKWAYLANDSINK-use-card0-as-default-drm-device.patch \
    file://0004-codecs-Force-to-add-math-as-library-dependency.patch \
    file://0005-v4l2codecs-vp8-Add-WebP-image-decoding-support.patch \
    file://0006-v4l2codecs-format-fix-I420-number-of-planes.patch \
    file://0007-v4l2codecs-format-Add-NV12M-format-support.patch \
    file://0008-v4l2codecs-format-Add-UYVY-format-support.patch \
    file://0009-v4l2codecs-format-Add-RGB-variants-format-support.patch \
    file://0010-v4l2codecs-format-Allow-matching-planar-format-varia.patch \
    file://0011-v4l2codecs-Add-V4L2-encoder-class.patch \
    file://0012-v4l2codecs-encoder-Add-colorimetry-support-at-sink-p.patch \
    file://0013-v4l2codecs-encoder-Add-rotation-support.patch \
    file://0014-codecs-Introduce-a-PID-based-rate-controller.patch \
    file://0015-codecs-Add-base-class-for-VP8-stateless-encoder.patch \
    file://0016-v4l2codecs-Add-V4L2-VP8-stateless-encode-uAPI.patch \
    file://0017-v4l2codecs-Add-V4L2-VP8-stateless-encoder.patch \
    file://0018-v4l2codecs-Register-V4L2-VP8-stateless-encoder.patch \
    file://0019-codecs-Add-base-class-for-H264-stateless-encoder.patch \
    file://0020-v4l2codecs-Add-V4L2-H264-stateless-encode-uAPI.patch \
    file://0021-v4l2codecs-Add-V4L2-H264-stateless-encoder.patch \
    file://0022-v4l2codecs-Register-V4L2-H264-stateless-encoder.patch \
    file://0023-wayland-gstwllinuxdmabuf.c-expand-timeout-at-dmabuf-.patch \
"

PACKAGECONFIG_GL ?= "${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'gles2 egl', '', d)}"
PACKAGECONFIG[gtk3] = "-Dgtk3=enabled,-Dgtk3=disabled,gtk+3"

PACKAGECONFIG ?= " \
    ${GSTREAMER_ORC} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'bluetooth', 'bluez', '', d)} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'directfb', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland gtk3', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'gl', '', d)} \
    bz2 closedcaption curl dash dtls hls rsvg sbc smoothstreaming sndfile \
    ttml uvch264 webp \
    faac kms \
    v4l2codecs \
"
# Vulkan is not activated by default, because on board wich have no gpu and no library
# they generate an issue with gst-inspect.

do_install:append() {
    install -d ${D}${includedir}/gstreamer-1.0/wayland
    install -m 644 ${S}/gst-libs/gst/wayland/wayland.h ${D}${includedir}/gstreamer-1.0/wayland
}
