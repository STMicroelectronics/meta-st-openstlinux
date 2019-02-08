PACKAGECONFIG = " ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'x11 xcb', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'egl glesv2', '', d)} \
    "

