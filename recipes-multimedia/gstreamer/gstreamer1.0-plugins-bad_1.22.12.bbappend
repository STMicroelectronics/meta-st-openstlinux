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
    file://0020-gtkwaylandsink-do-not-use-drm-dumb-pool-with-DMAbuf-.patch \
    file://0022-codecs-Add-base-class-for-stateless-vp8-encoder.patch \
    file://0023-v4l2codecs-Add-V4L2-VP8-stateless-encode-uAPI.patch \
    file://0024-v4l2codecs-Add-v4l2-encoder-class.patch \
    file://0025-v4l2codecs-Add-V4L2-stateless-VP8-encoder.patch \
    file://0026-v4l2codecs-Register-V4L2-stateless-Vp8-encoder.patch \
    file://0027-waylandsink-HACK-disable-frame-dropping-while-redraw.patch \
    file://0028-v4l2codecs-add-key-frame-signaling.patch \
    file://0029-gtkwaylandsink-HACK-disable-frame-dropping-while-red.patch \
    file://0031-v4l2codecs-fix-support-of-unaligned-videos.patch \
    file://0033-waylandsink-Fix-rendering-of-unaligned-content.patch \
    file://0035-v4l2codecs-add-NV12M-format-to-gstv4l2format.patch \
    file://0036-v4l2codecs-fix-gst_v4l2_encoder_set_src_fmt-call.patch \
    file://0037-v4l2codecs-add-support-of-encoding-from-RGB.patch \
    file://0038-v4l2codecs-add-colorimetry-support-at-sink-pad.patch \
    file://0040-Revert-v4l2codecs-fix-support-of-unaligned-videos.patch \
    file://0041-h264parser-Define-level-enum-values.patch \
    file://0042-codecparsers-keep-naming-consistency-in-GST_H264_LEV.patch \
    file://0043-v4l2codecs-encoder-No-need-to-set-num_planes-of-plan.patch \
    file://0044-v4l2codecs-add-NV12M-format-to-gstv4l2format.patch \
    file://0045-v4l2codecs-Add-V4L2-H264-stateless-encode-uAPI.patch \
    file://0046-codecs-Add-base-class-for-stateless-h264-encoder.patch \
    file://0047-v4l2codecs-encoder-Add-h264-code-to-v4l2-encoder-cla.patch \
    file://0048-v4l2codecs-Add-V4L2-stateless-H264-encoder.patch \
    file://0049-v4l2codecs-Register-V4L2-stateless-H264-encoder.patch \
    file://0050-v4l2codecs-encoders-Implement-propose-allocation.patch \
    file://0051-v4l2codecs-format-Allow-matching-planar-format-varia.patch \
    file://0052-v4l2codecs-encoder-Save-the-sink-format.patch \
    file://0053-v4l2codecs-format-Prefer-mplane-variants.patch \
    file://0054-v4l2codecs-encoder-Implement-zero-copy-support.patch \
    file://0055-codecs-h264enc-Fix-indentation.patch \
    file://0056-v4l2codecs-h264enc-Fix-indentation.patch \
    file://0057-v4l2codecs-h264enc-Cleanup-caps-colorimetry-framerat.patch \
    file://0058-v4l2codecs-h264enc-add-CABAC-enable-disable-control.patch \
    file://0059-v4l2codecs-h264enc-Don-t-call-virtual-negotiate-dire.patch \
    file://0060-v4l2codecs-vp8enc-Don-t-call-virtual-negotiate-direc.patch \
    file://0061-v4l2codecs-h264enc-Add-profile-negotiation.patch \
    file://0062-codecs-h264encoder-Fix-H.264-QP-max-value.patch \
    file://0063-v4l2codecs-h264dec-Remove-dead-and-broken-code.patch \
    file://0064-codecs-Introduce-a-PID-based-rate-controller.patch \
    file://0065-codecs-h264encoder-Use-the-PID-base-rate-controller.patch \
    file://0066-v4l2codecs-h264enc-Rewrite-profile-level-negotiation.patch \
    file://0067-v4l2codecs-h264enc-De-emulate-SPS-and-PPS-bitstream.patch \
    file://0068-v4l2codecs-vp8-fix-support-of-unaligned-videos.patch \
    file://0069-Force-to-add-math-as-library-dependency.patch \
    file://0070-v4l2codecs-sync-to-kernel-v6.6-headers.patch \
    file://0070-v4l2codecs-encoder-add-rotation-support.patch \
    file://0071-v4l2codecs-vp8-add-webp-image-support.patch \
    file://0072-jpegparse-don-t-trigger-message-for-failed-com-marke.patch \
    file://0073-kmsallocator-fix-stride-with-planar-formats.patch \
    file://0074-Revert-waylandsink-Fix-rendering-of-unaligned-conten.patch \
    file://0075-waylandsink-match-drm-kernel-driver-alignment.patch \
    file://0076-gtkwaylandsink-match-drm-kernel-driver-alignment.patch \
    file://0077-waylandsink-Add-gst_buffer_pool_config_set_params-to.patch \
    file://0078-gtkwaylandsink-Add-gst_buffer_pool_config_set_params.patch \
    file://0079-waylandsink-config-buffer-pool-with-query-size-when-.patch \
    file://0080-gtkwaylandsink-config-buffer-pool-with-query-size-wh.patch \
    file://0081-v4l2codecs-add-support-of-encoding-from-RGBA.patch \
    file://0082-Revert-waylandsink-match-drm-kernel-driver-alignment.patch \
    file://0083-Revert-gtkwaylandsink-match-drm-kernel-driver-alignm.patch \
    file://0084-v4l2codecs-h264enc-add-support-of-DCT-8x8.patch \
    file://0085-v4l2codecs-add-support-of-encoding-from-UYVY.patch \
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
