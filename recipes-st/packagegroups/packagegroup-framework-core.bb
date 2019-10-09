SUMMARY = "Framework core components for display and mutlimedia"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "\
            packagegroup-framework-core         \
            packagegroup-framework-core-display \
            packagegroup-framework-core-mm      \
            "

# Manage to provide all framework core packages with overall one
RDEPENDS_packagegroup-framework-core = "\
    packagegroup-framework-core-display \
    packagegroup-framework-core-mm      \
    "

SUMMARY_packagegroup-framework-core-display = "Framework core components for display"
RDEPENDS_packagegroup-framework-core-display = "\
    fb-test \
    "

SUMMARY_packagegroup-framework-core-mm = "Framework core components for multimedia"
RDEPENDS_packagegroup-framework-core-mm = "\
    tiff        \
    libv4l      \
    rc-keymaps  \
    ${@bb.utils.contains('DISTRO_FEATURES', 'gstreamer', 'packagegroup-gstreamer1-0', '', d)} \
    "
