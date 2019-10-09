SUMMARY = "Framework core extra components for display and mutlimedia"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "\
            packagegroup-framework-core-extra           \
            packagegroup-framework-core-extra-display   \
            packagegroup-framework-core-extra-mm        \
            "

# Manage to provide all framework core extra packages with overall one
RDEPENDS_packagegroup-framework-core-extra = "\
    packagegroup-framework-core-extra-display   \
    packagegroup-framework-core-extra-mm        \
"

SUMMARY_packagegroup-framework-core-extra-display = "Framework core extra components for display"
RDEPENDS_packagegroup-framework-core-extra-display = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston', '', d)}                        \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston-init', '', d)}                   \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston-examples', '', d)}               \
    ${@bb.utils.contains_any('DISTRO_FEATURES', '${GTK3DISTROFEATURES}', 'gtk+3', '', d)}       \
    ${@bb.utils.contains_any('DISTRO_FEATURES', '${GTK3DISTROFEATURES}', 'gtk+3-demo', '', d)}  \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland', '', d)}       \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xserver-xorg-xwayland', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'libx11-locale', '', d)}         \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'libx11', '', d)}                \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'libxcb', '', d)}                \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'libxcursor', '', d)}            \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xf86-input-evdev', '', d)}      \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xf86-input-mouse', '', d)}      \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xf86-input-keyboard', '', d)}   \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xclock', '', d)}                \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xeyes', '', d)}                 \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xinput', '', d)}                \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xkbcomp', '', d)}               \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xorg-minimal-fonts', '', d)}    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xterm', '', d)}                 \
    "

SUMMARY_packagegroup-framework-core-extra-mm = "Framework core extra components for multimedia"
RDEPENDS_packagegroup-framework-core-extra-mm = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'kmscube', '', d)} \
    qrencode    \
    qrenc       \
    "
