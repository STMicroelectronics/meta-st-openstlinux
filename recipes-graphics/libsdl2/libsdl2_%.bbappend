FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

PACKAGECONFIG_GL = ""
PACKAGECONFIG ??= " \
    ${PACKAGECONFIG_GL} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'alsa pulseaudio', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland gles2', '', d)} \
    ${@bb.utils.contains("TUNE_FEATURES", "neon","arm-neon","",d)} \
    kmsdrm \
"

EXTRA_OECMAKE += " \
        -DSDL_VIVANTE=OFF \
        -DSDL_VULKAN=OFF \
        -DSDL_OPENGL=OFF \
"
