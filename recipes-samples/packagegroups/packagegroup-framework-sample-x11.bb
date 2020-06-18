SUMMARY = "Framework sample x11 components"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit packagegroup features_check

REQUIRED_DISTRO_FEATURES = "x11"

RDEPENDS_${PN} = "\
    xkbcomp                 \
    libxcb                  \
    libxcursor              \
    xf86-input-evdev        \
    xf86-input-mouse        \
    xf86-input-keyboard     \
    xclock                  \
    xinput                  \
    xeyes                   \
    xorg-minimal-fonts      \
    xterm                   \
    libx11                  \
    \
    xf86-video-modesetting  \
    xinit                   \
    \
    encodings               \
    font-alias              \
    font-util               \
    mkfontdir               \
    mkfontscale             \
    \
    libxkbfile              \
    "
