FILESEXTRAPATHS:prepend:stm32mpcommon := "${THISDIR}/${PN}:"

SRC_URI:append:stm32mpcommon = " \
    file://0001-Allow-to-get-hdmi-output-with-several-outputs.patch \
    file://0002-Force-to-close-all-output.patch \
    file://0003-Disable-gles3.patch \
    file://0004-Revert-gl-renderer-Add-EGL_IMAGE_PRESERVED_KHR-to-ou.patch \
    file://0001-Remove-useless-code-from-new-Fragment-Shader.patch \
    "
SIMPLECLIENTS="egl,touch,dmabuf-v4l,dmabuf-egl"

PACKAGECONFIG ??= "${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'kms wayland egl clients', '', d)} \
                   ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xwayland', '', d)} \
                   ${@bb.utils.filter('DISTRO_FEATURES', 'systemd x11', d)} \
                   ${@bb.utils.contains_any('DISTRO_FEATURES', 'wayland x11', '', 'headless', d)} \
                   ${@oe.utils.conditional('VIRTUAL-RUNTIME_init_manager', 'sysvinit', 'launcher-libseat', '', d)} \
                   image-jpeg \
                   screenshare \
                   shell-desktop \
                   shell-fullscreen \
                   launch"

EXTRA_OEMESON += "-Ddeprecated-wl-shell=true"
