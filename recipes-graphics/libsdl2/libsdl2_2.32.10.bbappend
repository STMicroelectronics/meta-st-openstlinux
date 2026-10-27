FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://0001-Correction-of-bad-dlopen-for-libEGL.patch"

PACKAGECONFIG_GL = ""

PACKAGECONFIG ??= " \
    ${PACKAGECONFIG_GL} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'alsa pipewire pulseaudio vulkan', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland gles2', '', d)} \
    ${@bb.utils.contains("TUNE_FEATURES", "neon","arm-neon","",d)} \
    kmsdrm \
"

EXTRA_OECMAKE += " \
        -DSDL_VIVANTE=OFF \
        -DSDL_OPENGL=OFF \
"
