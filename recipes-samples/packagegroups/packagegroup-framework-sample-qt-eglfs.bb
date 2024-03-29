SUMMARY = "Framework sample qt components over eglfs"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit packagegroup features_check

CONFLICT_DISTRO_FEATURES = "x11 wayland"

RDEPENDS:${PN} = "\
    packagegroup-framework-sample-qt    \
    \
    openstlinux-qt-eglfs                \
    "
