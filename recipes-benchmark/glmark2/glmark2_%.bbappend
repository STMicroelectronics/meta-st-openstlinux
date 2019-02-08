FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

DEPENDS += " udev "

SRC_URI_remove = "file://0001-Fix-clang-warnings.patch"

SRCREV = "5e0e448ca2c3a37c0b2c7794bcd73a700f79aa4f"

PACKAGECONFIG = "${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'x11-gl x11-gles2', '', d)} \
                 ${@bb.utils.contains('DISTRO_FEATURES', 'wayland opengl', 'wayland-gles2', '', d)} \
                 drm-gles2"
