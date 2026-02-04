SUMMARY = "List of package to install on Userfs (with potential dependency)"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH := "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} += "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-launcher', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-gtk', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'installer-gtk', '', d)} \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-application-netdata-hotspot', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-application-camera', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-application-video', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-application-3d-cube', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'demo-application-bluetooth', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'splashscreen', 'psplash-drm-extra', '', d)} \
    \
    ${@bb.utils.contains('MACHINE_FEATURES', 'm4copro', 'm4projects-stm32mp1', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'm33copro', 'm33projects-stm32mp2', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'm0copro', 'm0projects-stm32mp2', '', d)} \
    linux-examples-stm32mp1 \
    "

AI_DEMO_APPLICATION = "${@bb.utils.contains('MACHINE_FEATURES', 'm4copro', 'ai-hand-char-reco-launcher', '', d)} "
RDEPENDS:${PN}:append:stm32mpcommon = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '${AI_DEMO_APPLICATION}', '', d)} \
    "

