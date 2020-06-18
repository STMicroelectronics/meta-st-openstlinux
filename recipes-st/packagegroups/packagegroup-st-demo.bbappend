RDEPENDS_${PN} += "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-launcher', '', d)} \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-application-netdata-hotspot', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-application-camera', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-application-video', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-application-3d-cube', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-application-bluetooth', '', d)} \
    "

AI_DEMO_APPLICATION = "${@bb.utils.contains('MACHINE_FEATURES', 'm4copro', 'ai-hand-char-reco-launcher', '', d)} "
RDEPENDS_${PN}_append_stm32mpcommon = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '${AI_DEMO_APPLICATION}', '', d)} \
    "

