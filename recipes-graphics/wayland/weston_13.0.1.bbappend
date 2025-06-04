FILESEXTRAPATHS:prepend:stm32mpcommon := "${THISDIR}/${PN}:"

SRC_URI:append:stm32mpcommon = " \
    file://0001-Clone-mode-not-supported.patch \
    file://0002-Disable-request-to-EGL_DRM_RENDER_NODE_FILE_EXT.patch \
    file://0003-Revert-compositor-improve-opacity-handling-for-scale.patch \
    file://0004-Revert-compositor-set-transform.opaque-for-surfaces-.patch \
    file://0005-Stop-crtc-before-destroy.patch \
    "

SIMPLECLIENTS="egl,touch,dmabuf-v4l,dmabuf-egl"

PACKAGECONFIG ??= "${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'kms wayland egl clients', '', d)} \
                   ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xwayland', '', d)} \
                   ${@bb.utils.filter('DISTRO_FEATURES', 'systemd x11', d)} \
                   ${@bb.utils.contains_any('DISTRO_FEATURES', 'wayland x11', '', 'headless', d)} \
                   image-jpeg \
                   webp \
                   screenshare \
                   shell-desktop \
                   shell-fullscreen \
                   shell-kiosk \
                   remoting \
                "
