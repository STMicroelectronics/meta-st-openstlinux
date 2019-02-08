PACKAGE_INSTALL += "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-hotspot-wifi', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'ai-hand-char-reco-launcher', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-launcher', '', d)} \
    "
