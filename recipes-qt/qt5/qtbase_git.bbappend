FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG_GL = " ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'gles2', '', d)} "
PACKAGECONFIG:append = " eglfs examples accessibility "
QT_CONFIG_FLAGS += " -no-sse2 -no-opengles3"

SRC_URI += "file://0002-RHI-introduce-a-way-to-disable-framebuffer-clears-on.patch"
