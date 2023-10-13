FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

DEPENDS += " udev "

PACKAGECONFIG = "${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'x11-gl x11-gles2', '', d)} \
                 ${@bb.utils.contains('DISTRO_FEATURES', 'wayland opengl', 'wayland-gles2', '', d)} \
                 drm-gles2"

SRC_URI += " \
    file://0001-Add-support-for-Wayland-display-scale-events.patch \
    file://0002-Allow-flavours-to-generate-their-own-source-files.patch \
    file://0003-Port-Wayland-to-xdg-shell-window-management.patch"

# Add wayland-native to provide wayland-scanner tool for use at build time
PACKAGECONFIG[wayland-gles2] = ",,virtual/libgles2 wayland wayland-native"
