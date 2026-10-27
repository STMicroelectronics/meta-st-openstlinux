FILESEXTRAPATHS:prepend:stm32mpcommon := "${THISDIR}/${PN}:"

SRC_URI:append:stm32mpcommon = " \
    file://0001-Clone-mode-not-supported.patch \
    file://0002-Disable-request-to-EGL_DRM_RENDER_NODE_FILE_EXT.patch \
    file://0003-Revert-compositor-improve-opacity-handling-for-scale.patch \
    file://0004-Revert-compositor-set-transform.opaque-for-surfaces-.patch \
    file://0005-Stop-crtc-before-destroy.patch \
    \
    file://0006-gl-renderer-try-to-avoid-shader-swizzle-on-ES-2.patch \
    file://0007-compositor-Fix-rotated-opaque-surfaces.patch \
    file://0008-surface-state-Fix-assert-firing-when-subsurfaces-hav.patch \
    file://0009-gl-shaders-Allow-SHADER_VARIANT_RGBA-for-YUV-RGB-con.patch \
    file://0010-Revert-gl-renderer-Prefer-GL_RGBA8-with-swizzles-ove.patch \
"

SIMPLECLIENTS = "egl,touch,dmabuf-v4l,dmabuf-egl"

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
                   pipewire \
                   pipewire-plugin \
                "
PACKAGECONFIG[pipewire-plugin] = "-Dpipewire=true,-Dpipewire=false,pipewire"
EXTRA_OEMESON:remove = "-Dpipewire=false"
