PACKAGECONFIG = " ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'x11 xcb', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'egl glesv2', '', d)} \
    "

do_install_append() {
    install -d ${D}${bindir}/
    install -m 0755 ${B}/util/cairo-trace/cairo-trace ${D}${bindir}/
}
