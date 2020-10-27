FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

DEPENDS += " udev "

PACKAGECONFIG = "${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'x11-gl x11-gles2', '', d)} \
                 ${@bb.utils.contains('DISTRO_FEATURES', 'wayland opengl', 'wayland-gles2', '', d)} \
                 drm-gles2"
