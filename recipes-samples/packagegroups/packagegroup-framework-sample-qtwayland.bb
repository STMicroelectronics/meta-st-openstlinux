SUMMARY = "Framework sample qt components over QTwayland"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit packagegroup features_check

REQUIRED_DISTRO_FEATURES = "wayland"

RDEPENDS_${PN} = "\
    packagegroup-framework-sample-qt    \
    \
    qtwayland                           \
    qtwayland-plugins                   \
    openstlinux-qt-wayland              \
    "
